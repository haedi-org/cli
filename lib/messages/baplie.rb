module EDIFACT
    class BAPLIEMessage < Message
        def initialize(lines, interchange_version = '4', chars = DEFAULT_CHARS)
            super(lines, interchange_version, chars)
            @stowage_table = []
        end

        # LOC+147+0260284::5'
        # MEA+WT++KGM:3500'
        # LOC+9+SGSIN'
        # LOC+11+TZDAR'
        # LOC+83+TZDAR'
        # RFF+BM:1'
        # EQD+CN+EOLU6000828+45R1+++4'
        # NAD+CA+PL:172:ZZZ'

        def stowage_table
            @stowage_table = build_stowage_table if @stowage_table.blank?
            return @stowage_table
        end

        def build_stowage_table
            table = []
            table << [
                "CONTAINER ID",      #0
                "STOWAGE CELL",      #1
                "STOWAGE BAY",       #2
                "STOWAGE ROW",       #3
                "STOWAGE TIER",      #4
                "FULL/EMPTY",        #5
                "SIZE/TYPE",         #6
                "WEIGHT",            #7
                "CARRIER ID",        #8
                "PORT OF LOADING",   #9
                "PORT OF DISCHARGE", #10
                "PORT OF DELIVERY",  #11
                "BILL OF LADING",    #12
            ]
            for group in @groups do
                unless group.get_segments_by_tag("LOC").empty?
                    row = Array.new(table.first.length) { "" }
                    # LOCATION INFORMATION
                    for loc in group.get_segments_by_tag("LOC") do
                        case loc.location_qualifier.value
                            when "9" ; row[9]  = loc.location_id.readable
                            when "11"; row[10] = loc.location_id.readable
                            when "83"; row[11] = loc.location_id.readable
                        end
                        unless loc.stowage_location.blank?
                            row[1] = loc.location_id.value
                            row[2] = loc.stowage_location.bay
                            row[3] = loc.stowage_location.row
                            row[4] = loc.stowage_location.tier
                        end
                    end
                    # EQUIPMENT DETAILS
                    eqd = group.get_segments_by_tag("EQD").first
                    unless eqd.blank?
                        row[0] = eqd.equipment_id_number.value
                        row[5] = eqd.full_empty_indicator.readable
                        row[6] = eqd.equipment_size_and_type.readable
                    end
                    # REFERENCE INFORMATION
                    rff = group.get_segments_by_tag("RFF").first
                    unless rff.blank?
                        row[12] = rff.reference_number.readable
                    end
                    # NAME AND ADDRESS
                    nad = group.get_segments_by_tag("NAD").first
                    unless nad.blank?
                        row[8] = nad.party_identification.readable
                    end
                    # Measure
                    mea = group.get_segments_by_tag("MEA").first
                    unless mea.blank?
                        row[7] = mea.measurement_value.value
                    end
                    table << row unless row.first.blank?
                end
            end
            return table
        end

        def stowage_row_sort(arr)
            # Row ordering, e.g:
            # 14 12 10 08 06 04 02 00 01 03 05 07 09 11 13
            evens = arr.select { |n| n.to_i % 2 == 0 }
            odds  = arr.select { |n| n.to_i % 2 == 1 }
            return evens.sort.reverse + odds.sort
        end

        def stowage_ranges
            bays, rows, tiers = [], [], []
            for table_row in stowage_table[1..-1] do
                bays  << table_row[2]
                rows  << table_row[3]
                tiers << table_row[4]
            end
            return [
                bays.uniq.sort, 
                stowage_row_sort(rows.uniq), 
                tiers.uniq.sort.reverse,
            ]
        end

        def stowage_hash_map
            map = {}
            for table_row in stowage_table[1..-1] do
                map[table_row[1]] = true
            end
            return map
        end

        def debug
            out = []
            bays, rows, tiers = stowage_ranges
            out << [bays.join(","), bays.length]
            out << [rows.join(","), rows.length]
            out << [tiers.join(","), tiers.length]
            #for row in container_table do
            #    if row[2] == "001"
            #        puts row.join("\t")
            #    end
            #end
            return out
        end
    end
end
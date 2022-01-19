module EDIFACT
    Stowage = Struct.new(
        :container_id,
        :stowage_cell,
        :bay,
        :row,
        :tier,
        :full_empty,
        :size_type,
        :weight,
        :carrier_id,
        :port_of_loading,
        :port_of_discharge,
        :port_of_delivery,
        :bill_of_lading,
    )

    class BAPLIEMessage < Message
        def initialize(
            lines, interchange_version = '4', chars = DEFAULT_CHARS, 
            application_reference = nil)
            super(lines, interchange_version, chars, application_reference)
            @stowage_list = []
        end

        # LOC+147+0260284::5'
        # MEA+WT++KGM:3500'
        # LOC+9+SGSIN'
        # LOC+11+TZDAR'
        # LOC+83+TZDAR'
        # RFF+BM:1'
        # EQD+CN+EOLU6000828+45R1+++4'
        # NAD+CA+PL:172:ZZZ'

        def stowage_list
            @stowage_list = build_stowage_list if @stowage_list.blank?
            return @stowage_list
        end

        def build_stowage_list
            list = []
            for group in @groups do
                unless group.get_segments_by_tag("LOC").empty?
                    args = Array.new(13) { "" }
                    # LOCATION INFORMATION
                    for loc in group.get_segments_by_tag("LOC") do
                        case loc.location_qualifier.value
                            when "9" ; args[9]  = loc.location_id.readable
                            when "11"; args[10] = loc.location_id.readable
                            when "83"; args[11] = loc.location_id.readable
                        end
                        unless loc.stowage_location.blank?
                            args[1] = loc.location_id.value
                            args[2] = loc.stowage_location.bay
                            args[3] = loc.stowage_location.row
                            args[4] = loc.stowage_location.tier
                        end
                    end
                    # EQUIPMENT DETAILS
                    eqd = group.get_segments_by_tag("EQD").first
                    unless eqd.blank?
                        args[0] = eqd.equipment_id_number.value
                        args[5] = eqd.full_empty_indicator.readable
                        args[6] = eqd.equipment_size_and_type.readable
                    end
                    # REFERENCE INFORMATION
                    rff = group.get_segments_by_tag("RFF").first
                    unless rff.blank?
                        args[12] = rff.reference_number.readable
                    end
                    # NAME AND ADDRESS
                    nad = group.get_segments_by_tag("NAD").first
                    unless nad.blank?
                        args[8] = nad.party_identification.readable
                    end
                    # Measure
                    mea = group.get_segments_by_tag("MEA").first
                    unless mea.blank?
                        args[7] = mea.measurement_value.value
                    end
                    list << Stowage.new(*args) unless args.first.blank?
                end
            end
            return list
        end

        def carrier_list
            arr = []
            for stowage in stowage_list do
                arr << stowage.carrier_id
            end
            return arr.uniq
        end

        def stowage_row_sort(arr)
            # Row ordering, e.g:
            # 14 12 10 08 06 04 02 00 01 03 05 07 09 11 13
            evens = arr.select { |n| n.to_i % 2 == 0 }
            odds  = arr.select { |n| n.to_i % 2 == 1 }
            return evens.sort.reverse + odds.sort
        end

        def stowage_table
            return stowage_list.map do |stow|
                [
                    stow.container_id,
                    stow.stowage_cell,
                    stow.bay,
                    stow.row,
                    stow.tier,
                    stow.full_empty,
                    stow.size_type,
                    stow.weight,
                    stow.carrier_id,
                    stow.port_of_loading,
                    stow.port_of_discharge,
                    stow.port_of_delivery,
                    stow.bill_of_lading,
                ]
            end
        end

        def stowage_ranges
            bays, rows, tiers = [], [], []
            for stowage in stowage_list do
                bays  << stowage.bay
                rows  << stowage.row
                tiers << stowage.tier
            end
            return [
                bays.uniq.sort, 
                stowage_row_sort(rows.uniq), 
                tiers.uniq.sort.reverse,
            ]
        end

        def stowage_hash_map
            map = {}
            for stowage in stowage_list do
                map[stowage.stowage_cell] = stowage
            end
            return map
        end

        def debug
            out = []
            for stow in stowage_list.flatten.compact do
                puts stow.size_type
            end
            #bays, rows, tiers = stowage_ranges
            #out << [bays.join(","), bays.length]
            #out << [rows.join(","), rows.length]
            #out << [tiers.join(","), tiers.length]
            #for row in container_table do
            #    if row[2] == "001"
            #        puts row.join("\t")
            #    end
            #end
            return out
        end
    end
end
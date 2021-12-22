module EDIFACT
    class BAPLIEMessage < Message
        def initialize(lines, interchange_version = '4', chars = DEFAULT_CHARS)
            super(lines, interchange_version, chars)
        end

        # LOC+147+0260284::5'
        # MEA+WT++KGM:3500'
        # LOC+9+SGSIN'
        # LOC+11+TZDAR'
        # LOC+83+TZDAR'
        # RFF+BM:1'
        # EQD+CN+EOLU6000828+45R1+++4'
        # NAD+CA+PL:172:ZZZ'

        def container_table
            table = []
            table << [
                "CONTAINER ID",      # Row #0
                "STOWAGE CELL",      # Row #1
                "STOWAGE BAY",       # Row #2
                "STOWAGE ROW",       # Row #3
                "STOWAGE TIER",      # Row #4
                "FULL/EMPTY",        # Row #5
                "SIZE/TYPE",         # Row #6
                "WEIGHT",            # Row #7
                "CARRIER ID",        # Row #8
                "PORT OF LOADING",   # Row #9
                "PORT OF DISCHARGE", # Row #10
                "PORT OF DELIVERY",  # Row #11
                "BILL OF LADING",    # Row #12
            ]
            for group in @groups do
                unless group.get_segments_by_tag("LOC").empty?
                    row = Array.new(table.first.length) { "" }
                    # LOCATION INFORMATION
                    for loc in group.get_segments_by_tag("LOC") do
                        case loc.location_qualifier.value
                            when "9" ; row[9]  = loc.location_id.readable
                            when "11"; row[10]  = loc.location_id.readable
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

        def debug
            out = []
            CSV.open("./test.csv", "w") do |csv|
                for row in container_table do
                    csv << row
                end
            end
            
            #for group in @groups do
            #    unless group.get_segments_by_tag("LOC").empty?
            #        for loc in group.get_segments_by_tag("LOC") do
            #            out << "LOCATION #{loc.location_qualifier.readable.upcase}"
            #            out << "  Code: " + loc.location_qualifier.value
            #            out << "  ID: " + loc.location_id.readable unless loc.location_id.blank?
            #            out << "  Agency: " + loc.location_responsible_agency.readable unless loc.location_responsible_agency.blank?
            #            unless loc.stowage_location.blank?
            #                out << "  Bay: "  + loc.stowage_location.bay
            #                out << "  Row: "  + loc.stowage_location.row
            #                out << "  Tier: " + loc.stowage_location.tier
            #            end
            #        end
            #        # Equipment details
            #        eqd = group.get_segments_by_tag("EQD").first
            #        unless eqd.blank?
            #            out << "EQUIPMENT DETAILS"
            #            out << "  Equipment: " + eqd.equipment_qualifier.readable
            #            out << "  ID: " + eqd.equipment_id_number.readable
            #            out << "  Full/Empty: " + eqd.full_empty_indicator.readable
            #            out << "  Size/Type: " + eqd.equipment_size_and_type.readable
            #        end
            #        # Reference
            #        rff = group.get_segments_by_tag("RFF").first
            #        unless rff.blank?
            #            out << "REFERENCE"
            #            out << "  Qualifier: " + rff.reference_qualifier.readable
            #            out << "  Number: " + rff.reference_number.readable
            #        end
            #        # Name and address
            #        nad = group.get_segments_by_tag("NAD").first
            #        unless nad.blank?
            #            out << "NAME AND ADDRESS"
            #            out << "  Raw: " + nad.raw
            #            out << "  Qualifier: " + nad.party_qualifier.readable
            #            out << "  ID: " + nad.party_identification.readable
            #            out << "  Code list: " + nad.party_code_list.readable
            #            out << "  Agency: " + nad.party_responsible_agency.readable
            #        end
            #        # Measure
            #        out << ""
            #    end
            #end
            return out
        end
    end
end
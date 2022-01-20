module EDIFACT

    StowageLocation = Struct.new(:bay, :row, :tier)

    class LOCSegment < Segment
        attr_reader :location_qualifier
        attr_reader :location_id
        attr_reader :location_responsible_agency
        attr_reader :stowage_location

        def initialize(raw, line_no, version = nil, chars = nil, subset = nil)
            super(raw, line_no, version, chars)
            @stowage_location = nil
            # 010
            @location_qualifier = get_elements_by_code("3227").first
            # 020
            @location_id = get_elements_by_code("3225").first
            @location_responsible_agency = get_elements_by_code("3055")[0]
            # 030
            @location_one_id = get_elements_by_code("3223").first
            # 040
            @location_two_id = get_elements_by_code("3233").first
            # 050
            @relation = get_elements_by_code("5479").first
            #
            apply_code_list()
        end

        def apply_code_list
            if @location_responsible_agency.value == "5"
                # ISO 9711
                unless @location_id.blank?
                    @location_id.value.tap do |id|
                        bay  = id.length >= 3 ? id[0, 3] : nil
                        row  = id.length >= 5 ? id[3, 2] : nil
                        tier = id.length >= 7 ? id[5, 2] : nil
                        @stowage_location = StowageLocation.new(bay, row, tier)
                    end
                end
            end
            # Attempt to apply UN/LOCODE or SMDG TERMINALS to location ID
            data = $dictionary.code_list_lookup(
                "306", "UNLOCODE", @location_id.value
            )
            if data.blank?
                data = $dictionary.code_list_lookup(
                    "306", "TERMINALS", @location_id.value
                )
            end
            unless data.blank?
                @location_id.set_data_name(data["name"])
                @location_id.set_data_desc(data["desc"])
            end
        end

        def debug
            out = []
            return out
        end
    end
end

# BAPLIE requires stowage locations on container vessels
# to be identified according to ISO 9711 in format BBBRRTT:
# (BBB = bay number, RR = row number, TT = tier number).

# 0   1   20      21 22
# LOC+147+0330204:  :5'

# 0   1  2
# LOC+11+00FRB'

# 010  3227  Place/location qualifier                   M  1  an..3
# 020  C517  LOCATION IDENTIFICATION                    C  1
#      3225  Place/location identification              C     an..25
#      1131  Code list qualifier                        C     an..3
#      3055  Code list responsible agency, coded        C     an..3
#      3224  Place/location                             C     an..70
# 030  C519  RELATED LOCATION ONE IDENTIFICATION        C  1
#      3223  Related place/location one identification  C     an..25
#      1131  Code list qualifier                        C     an..3
#      3055  Code list responsible agency, coded        C     an..3
#      3222  Related place/location one                 C     an..70
# 040  C553  RELATED LOCATION TWO IDENTIFICATION        C  1
#      3233  Related place/location two identification  C     an..25
#      1131  Code list qualifier                        C     an..3
#      3055  Code list responsible agency, coded        C     an..3
#      3232  Related place/location two                 C     an..70
# 050  5479  Relation, coded                            C  1  an..3
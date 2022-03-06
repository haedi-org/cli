module EDIFACT
    class ERCSegment < Segment
        attr_reader :application_error_id
        attr_reader :code_list_qualifier, :responsible_agency
        
        def initialize(raw, line_no, version = nil, chars = nil, subset = nil)
            super(raw, line_no, version, chars, subset)
            @application_error_id = get_elements_by_code("9321").first
            @code_list_qualifier = get_elements_by_code("1131").first
            @responsible_agency = get_elements_by_code("3055").first
            apply_code_list()
        end

        def apply_code_list
            data = $dictionary.code_list_lookup(
                @responsible_agency.value,
                @code_list_qualifier.value,
                @application_error_id.value
            )
            unless data.blank?
                @application_error_id.set_data_name(data["name"])
                @application_error_id.set_data_desc(data["desc"])
            end
        end
    end
end

# 010  C901  APPLICATION ERROR DETAIL             M  1
#      9321  Application error identification     M     an..8
#      1131  Code list qualifier                  C     an..3
#      3055  Code list responsible agency, coded  C     an..3
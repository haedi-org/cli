module EDIFACT
    class FTXSegment < Segment
        attr_reader :free_text_identification
        attr_reader :code_list_qualifier, :responsible_agency

        def initialize(raw, line_no, version = nil, chars = nil, subset = nil)
            super(raw, line_no, version, chars, subset)
            @free_text_identification = get_elements_by_code("4441").first
            @code_list_qualifier = get_elements_by_code("1131").first
            @responsible_agency = get_elements_by_code("3055").first
            apply_code_list()
        end

        def apply_code_list
            data = $dictionary.code_list_lookup(
                @responsible_agency.value,
                @code_list_qualifier.value,
                @free_text_identification.value
            )
            unless data.blank?
                @free_text_identification.set_data_name(data["name"])
                @free_text_identification.set_data_desc(data["desc"])
            end
        end
    end
end

# 010  4451  Text subject qualifier               M  1  an..3
# 020  4453  Text function, coded                 C  1  an..3
# 030  C107  TEXT REFERENCE                       C  1
#      4441  Free text identification             M     an..17
#      1131  Code list qualifier                  C     an..3
#      3055  Code list responsible agency, coded  C     an..3
# 040  C108  TEXT LITERAL                         C  1
#      4440  Free text                            M     an..70
#      4440  Free text                            C     an..70
#      4440  Free text                            C     an..70
#      4440  Free text                            C     an..70
#      4440  Free text                            C     an..70
# 050  3453  Language, coded                      C  1  an..3
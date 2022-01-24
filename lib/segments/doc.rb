module EDIFACT
    class DOCSegment < Segment
        attr_reader :document_name
        attr_reader :code_list_qualifier, :responsible_agency

        def initialize(raw, line_no, version = nil, chars = nil, subset = nil)
            super(raw, line_no, version, chars, subset)
            @document_name = get_elements_by_code("1001").first
            @code_list_qualifier = get_elements_by_code("1131").first
            @responsible_agency = get_elements_by_code("3055").first
            apply_code_list()
        end

        def apply_code_list
            data = $dictionary.code_list_lookup(
                @responsible_agency.value,
                @code_list_qualifier.value,
                @document_name.value
            )
            unless data.blank?
                @document_name.set_data_name(data["name"])
                @document_name.set_data_desc(data["desc"])
            end
        end
    end
end

# 010  C002  DOCUMENT/MESSAGE NAME                     M  1
#      1001  Document/message name, coded              C     an..3
#      1131  Code list qualifier                       C     an..3
#      3055  Code list responsible agency, coded       C     an..3
#      1000  Document/message name                     C     an..35
# 020  C503  DOCUMENT/MESSAGE DETAILS                  C  1
#      1004  Document/message number                   C     an..35
#      1373  Document/message status, coded            C     an..3
#      1366  Document/message source                   C     an..35
#      3453  Language, coded                           C     an..3
# 030  3153  Communication channel identifier, coded   C  1  an..3
# 040  1220  Number of copies of document required     C  1  n..2
# 050  1218  Number of originals of document required  C  1  n..2
module EDIFACT
    class BGMSegment < Segment
        attr_reader :document_name, :document_number

        def initialize(raw, line_no, version = nil, chars = nil, subset = nil)
            super(raw, line_no, version, chars, subset)
            @document_name = get_elements_by_code("1001").first
            @document_number = get_elements_by_code("1004").first
        end
    end
end

# 010   C002  DOCUMENT/MESSAGE NAME                C  1
# 1001        Document/message name, coded         C     an..3
# 1131        Code list qualifier                  C     an..3
# 3055        Code list responsible agency, coded  C     an..3
# 1000        Document/message name                C     an..35
# 020   C106  DOCUMENT/MESSAGE IDENTIFICATION      C  1
# 1004        Document/message number              C     an..35
# 1056        Version                              C     an..9
# 1060        Revision number                      C     an..6
# 030   1225  Message function, coded              C  1  an..3
# 040   4343  Response type, coded                 C  1  an..3
module EDIFACT
    class RFFSegment < Segment
        attr_reader :reference_qualifier, :reference_number

        def initialize(raw, line_no, version = nil, chars = nil, subset = nil)
            super(raw, line_no, version, chars)
            @reference_qualifier = get_elements_by_code("1153").first
            @reference_number = get_elements_by_code("1154").first
        end
    end
end

# 010  C506  REFERENCE                 M  1
#      1153  Reference qualifier       M     an..3
#      1154  Reference number          C     an..35
#      1156  Line number               C     an..6
#      4000  Reference version number  C     an..35	
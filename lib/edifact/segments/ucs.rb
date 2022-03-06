module EDIFACT
    class UCSSegment < Segment
        attr_reader :segment_position_in_body, :syntax_error

        def initialize(raw, line_no, version = nil, chars = nil, subset = nil)
            super(raw, line_no, version, chars, subset)
            @segment_position_in_body = get_elements_by_code("0096").first
            @syntax_error = get_elements_by_code("0085").first
        end
    end
end

# 010  0096  Segment position in message body  M  1  n..6
# 020  0085  Syntax error, coded               C  1  an..3
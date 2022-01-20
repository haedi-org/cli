module EDIFACT
    class UNTSegment < Segment
        attr_reader :number_of_segments, :message_reference_number

        def initialize(raw, line_no, version = nil, chars = nil, subset = nil)
            super(raw, line_no, version, chars, subset)
            @number_of_segments = get_elements_by_code("0074").first
            @message_reference_number = get_elements_by_code("0062").first
        end
    end
end

# UNT+22+SSDD1'
#     ^ Number of segments in a message
#        ^ Message reference number

# 010  0074  NUMBER OF SEGMENTS IN A MESSAGE  M  1  n..6
# 020  0062  MESSAGE REFERENCE NUMBER         M  1  an..14
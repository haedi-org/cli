module EDIFACT
    class SegmentFactory
        attr_reader :segment

        def initialize(str, line_no = 0, version = nil, chars = DEFAULT_CHARS)
            tag = str.first(3)
            params = [str, line_no, version, chars]
            begin
                if SEGMENT_MAP.include?(tag)
                    @segment = SEGMENT_MAP[tag].new(*params)
                else
                    @segment = Segment.new(*params)
                end
            rescue => exception
                puts exception
                puts exception.backtrace
            end
        end
    end
end
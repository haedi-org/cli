# Lines given in the form [[line_no, line_data], [line_no, line_data], ...]
# [[2, "UNH+SSDD1+ORDERS:D:03B:UN:EAN008'"], [3, "BGM+220+BKOD99+9'"], ...]

module EDIFACT
    class Group
        attr_reader :name, :segments

        def initialize(name, lines, message_version, chars, subset = nil)
            # Define values from given arguments
            @name, @lines = name, lines
            @message_version, @chars, @subset = message_version, chars, subset
            # Define segments list and errors list
            @segments, @errors = [], []
            # Initial methods to generate objects
            set_segments()
        end

        def is_valid?
            return errors().empty?
        end

        def errors
            segment_errors = []
            for segment in @segments do
                unless segment.is_valid?
                    segment_errors += segment.errors
                end
            end
            return (@errors + segment_errors).compact
        end
        
        def raw
            return @segments.map { |segment| segment.raw }
        end

        def set_segments()
            for line_no, line_data in @lines do
                params = [line_data, line_no, @message_version, @chars, @subset]
                @segments << SegmentFactory.new(*params).segment
            end
        end

        def get_segments_by_tag(tag)
            arr = []
            for segment in @segments.compact do
                arr << segment if segment.tag.value == tag
            end
            return arr
        end
    end
end
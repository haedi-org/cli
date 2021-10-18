class Document
    attr_reader :raw
    attr_reader :segments
    attr_reader :version
    attr_reader :message_type
    attr_reader :chars

    def initialize(lines)
        @raw = lines.dup
        @segments = @raw.map { |line| line.chomp }.join
        set_critical_values(lines)
        # Create segment objects
        @segments.map!.with_index do |segment, line_no|
            begin
                params = [segment, line_no, @version, @chars]
                if SEGMENT_MAP.include?(segment.first(3))
                    SEGMENT_MAP[segment.first(3)].new(*params)
                else
                    Segment.new(*params)
                end
            rescue => exception
                puts exception
                puts exception.backtrace
            end
        end
    end
    
    def debug
        out = []
        for segment in @segments do
            out << segment.debug
        end
        return out
    end

    def set_critical_values(lines)
        # Get punctuation values from UNA line
        una = @segments.first(3) == "UNA" ? @segments.first(9) : nil
        @chars = format_punctuation(una)
        # Split by segment terminator
        te = @chars.segment_terminator
        re = @chars.release_character
        @segments = @segments.split_with_release(te, re).map { |s| s + te }
        # Fix UNA segment
        @segments[0] = una if @segments[0].first(3) == "UNA"
        # Save unedited lines
        @raw = @segments.dup
        # Get document information
        @segments.each_with_index do |segment, line_no|
            if segment.first(3) == "UNH"
                unh = UNHSegment.new(segment, line_no, @version, @chars)
                @version = unh.version_key
                @message_type = unh.message_type.value
            end
        end
    end

    def assign_values
        puts "TESTTESTTEST"
        # Get punctuation values from UNA line
        una = segments.first(3) == "UNA" ? lines.first(9) : nil
        @chars = format_punctuation(una)
        # Split by segment terminator
        te = @chars.segment_terminator
        re = @chars.release_character
        @segments = @segments
            .split_with_release(te, re).map { |line| line + te }
        # Fix UNA segment
        @lines[0] = una if @lines[0].first(3) == "UNA"
        # Save unedited lines
        @raw = @segments.dup
        # Get document information
        @segments.each_with_index do |segment, line_no|
            puts segment.first(3)
            if segment.first(3) == "UNH"
                unh = UNHSegment.new(segment, line_no, @version, @chars)
                @version = unh.version_key
                @message_type = unh.message_type.value
            end
        end
    end

    def format_punctuation(line = nil)
        unless line == nil
            return UNASegment.new(line, 0, @version).punctuation
        else
            return Punctuation.new(':', '+', '.', '?', ' ', '\'')
        end
    end

    def rows
        return @lines.map { |line| [line.tag, line.rows] }
    end

    def timeline
        times = []
        @lines.each do |line|
            if line.tag.value == "UNB"
                times << ["Preparation date time", line.time + " " + line.date]
            end
            if line.tag.value == "DTM"
                times << [line.qualifier.ref, line.interpret]
            end
        end
        return times.sort { |a, b| Time.parse(a[1]) <=> Time.parse(b[1]) }
    end
end
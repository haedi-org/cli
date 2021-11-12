class Document
    attr_reader :raw
    attr_reader :segments
    attr_reader :version
    attr_reader :message_type
    attr_reader :chars
    attr_reader :controlling_agency
    attr_reader :association_assigned_code

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
                @controlling_agency = unh.controlling_agency.value
                @association_assigned_code = unh.association_assigned_code.value
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
        events = []
        @segments.each do |segment|
            if segment.tag.value == "DTM"
                events << [
                    segment.date_time_qualifier.readable, 
                    segment.date_time.readable
                ]
            end
        end
        return events.sort { |a, b| Time.parse(a[1]) <=> Time.parse(b[1]) }
    end
end
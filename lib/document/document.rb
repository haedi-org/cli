class Document
    attr_reader :raw
    attr_reader :lines
    attr_reader :version
    attr_reader :message

    def initialize(lines)
        @raw = lines.dup
        @segments = @raw.map { |line| line.chomp }.join
        @version = "D97A" # nil
        # 
        set_critical_values
        # Create segment objects
        @segments.map!.with_index do |segment, line_no|
            begin
                params = [segment, line_no, @version, @chars]
                Segment.new(*params)
            rescue => exception
                puts exception
                puts exception.backtrace
            end
        end


    #    # Get critical values from document and reformat
    #    assign_values
    #    # Create line object dependant on tag
    #    @lines.map!.with_index do |line, line_no|
    #        begin
    #            params = [line, line_no, @version, @chars]
    #            unless SEGMENT_MAP.include?(line.first(3))
    #                Line.new(*params)
    #            else
    #                SEGMENT_MAP[line.first(3)].new(*params)
    #            end
    #        rescue => exception
    #            #html_error(exception)
    #            puts exception
    #            puts exception.backtrace
    #            exit
    #        end
    #    end
    end
    
    def debug
        out = []
        for segment in @segments do
            out << segment.debug
        end
        return out
    end

    def set_critical_values
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
    end

    def assign_values
        # Get punctuation values from UNA line
        una = lines.first(3) == "UNA" ? lines.first(9) : nil
        @chars = format_punctuation(una)
        # Split by segment terminator
        te = @chars.segment_terminator
        re = @chars.release_character
        @lines = @lines.split_with_release(te, re).map { |line| line + te }
        # Fix UNA segment
        @lines[0] = una if @lines[0].first(3) == "UNA"
        # Save unedited lines
        @raw = @lines.dup
        # Get document information
        @lines.each_with_index do |line, line_no|
            if line.first(3) == "UNH"
                unh = UNH.new(line, line_no, @version, @chars)
                @version = unh.message_version
                @message = unh.message_type
            end
        end
    end

    def format_punctuation(line = nil)
        unless line == nil
            return UNA.new(line, 0, @version).punctuation
        else
            return Punctuation.new(':', '+', '.', '?', '\'')
        end
    end

    def structure
        data = lookup_structure(@message.value, @version.ref)
        unless data == {}
            return Structure.new(self, data)
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
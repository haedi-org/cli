class Document
    attr_reader :raw, :lines, :version, :message

    def initialize(lines)
        @raw = lines.dup
        @lines = @raw.map { |line| line.chomp }.join
        @version = nil
        # Get critical values from document and reformat
        assign_values
        # Create line object dependant on tag
        @lines.map!.with_index do |line, line_no|
            begin
                params = [line, line_no, @version, @chars]
                unless SEGMENT_MAP.include?(line.first(3))
                    Line.new(*params)
                else
                    SEGMENT_MAP[line.first(3)].new(*params)
                end
            rescue => exception
                html_error(exception)
               #puts exception
               #puts exception.backtrace
                exit
            end
        end
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
        return @lines.map { |line| line.rows }
    end
    
    def debug
        out = []
        @lines.each do |line|
            unless line.is_a?(UNA)
                line.table.each do |row|
                    out += [row.join("\t, "), "\n"]
                end
            end
        end
        return out
    end

    def info
        data = {}
        for line in @lines do
            # Interchange header segment information
            if line.is_a?(UNB)
                data[:sender_identifier] = line.sender_id.value
                data[:recipient_identifier] = line.recipient_id.value
            end
            # Message header segment information
            if line.is_a?(UNH)
                data[:message_reference] = line.message_reference.value
                data[:message_type] = line.message_type.value
                data[:message_version] = line.message_version.ref
                unless line.controlling_agency.blank?
                    data[:controlling_agency] = line.controlling_agency.value
                end
                unless line.association_code.blank?
                    data[:association_code] = line.association_code.value
                end
            end
            # Date/time/period segment information
            if line.is_a?(DTM) && (!line.qualifier.interpreted.blank?)
                data[line.qualifier.interpreted] = line.date.interpreted
            end
            # Reference segment information
            if line.is_a?(RFF) && (!line.reference.interpreted.blank?)
                data[line.reference.interpreted] = line.reference_number.value
            end
        end
        return data
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
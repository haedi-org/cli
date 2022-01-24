module EDIFACT
    class Interchange
        attr_reader :path, :raw
        attr_reader :header, :trailer, :version
        attr_reader :application_reference
        attr_reader :load_time, :process_time

        def initialize(path)
            start_process_time = Time.now
            @path = path
            @raw = load_from_file(path)
            @lines = @raw.map { |line| line.chomp }.join
            @header = nil
            @messages = []
            @trailer = nil
            @version = '4'
            @chars = nil
            @errors = []
            @application_reference = nil
            # Initial methods
            set_punctuation_values()
            split_lines_by_terminator()
            set_interchange_envelope()
            set_critical_values()
            set_messages()
            @process_time = Time.now - start_process_time
        end

        def messages(filter = nil)
            return @messages.compact if filter == nil
            return @messages.compact.select { |message| message.is_a?(filter) }
        end

        def load_from_file(path = @path)
            start_load_time = Time.now
            lines = File.readlines(path, :encoding => "UTF-8")
            @load_time = Time.now - start_load_time
            return lines
        end

        def get_una_segment()
            if @lines.first(3) == "UNA"
                return SegmentFactory.new(@lines.first(9)).segment
            else
                return nil
            end
        end

        def set_punctuation_values()
            # Get punctuation values from UNA line
            una_segment = get_una_segment()
            unless una_segment.blank?
                @chars = una_segment.punctuation
            else
                @chars = DEFAULT_CHARS
            end
        end

        def split_lines_by_terminator()
            # Grab UNA segment
            una = @lines.first(3) == "UNA" ? @lines.first(9) : nil
            # Split by segment terminator
            te = @chars.segment_terminator
            re = @chars.release_character
            @lines = @lines.split_with_release(te, re).map { |s| s + te }
            # Configure UNA segment correctly
            @lines[0] = una unless una.blank?
        end

        def set_interchange_envelope()
            @lines.each_with_index do |line, line_no|
                params = [line, line_no, @version, @chars]
                # Header
                if line.first(3) == "UNB"
                    if @header == nil
                        @header = SegmentFactory.new(*params).segment
                    else
                        # Duplicate UNB segment
                        @errors << InterchangeHeaderDuplicateError.new
                    end
                end
                # Trailer
                if line.first(3) == "UNZ"
                    if @trailer == nil
                        @trailer = SegmentFactory.new(*params).segment
                    else
                        # Duplicate UNZ segment
                        @errors << InterchangeTrailerDuplicateError.new
                    end
                end
            end
        end

        def set_critical_values()
            unless @header.blank?
                @application_reference = @header.application_reference.value
            end
            unless @footer.blank?
                # ...
            end
        end

        def group_lines_by_envelope(opener, closer)
            groups, group, is_opened = [], [], false
            line_no = -1
            for line_data in @lines do
                line_no += 1
                is_opened = true if line_data.first(3) == opener
                group << [line_no, line_data] if is_opened
                if line_data.first(3) == closer
                    is_opened = false
                    groups << group
                    group = []
                end
            end
            groups << group unless group.empty?
            return groups
        end

        def set_messages()
            @messages = group_lines_by_envelope('UNH', 'UNT').map! do |lines|
                params = [lines, @version, @chars, @application_reference]
                MessageFactory.new(*params).message
            end
        end

        def segments()
            arr = []
            arr << @header
            for message in @messages do
               #arr << message.header
                for group in message.groups do
                    arr << group.segments
                end
               #arr << message.trailer
            end
            arr << @trailer
            return arr.flatten.compact
        end

        def timelines()
            return @messages.map { |message| message.timeline }
        end
    end
end

# Interchange header (UNB)
# UNB+UNOB:4+STYLUSSTUDIO:1+DATADIRECT:1+20051107:1159+6002'

# Interchange trailer (UNZ)
# UNZ+1+6002'
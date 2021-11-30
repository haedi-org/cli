class Interchange
    attr_reader :header, :trailer
    attr_reader :messages, :version

    def initialize(path)
        @path = path
        @raw = load_from_file(path)
        @lines = @raw.map { |line| line.chomp }.join
        @header = nil
        @messages = []
        @trailer = nil
        @version = '4'
        @chars = nil
        # Initial methods
        set_punctuation_values()
        split_lines_by_terminator()
        set_messages()
    end

    def load_from_file(path = @path)
        return File.readlines(path)
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
            Message.new(lines, @version, @chars)
        end
    end
end

# Interchange header (UNB)
# UNB+UNOB:4+STYLUSSTUDIO:1+DATADIRECT:1+20051107:1159+6002'

# Interchange trailer (UNZ)
# UNZ+1+6002'
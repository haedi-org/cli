# Lines given in the form [[line_no, line_data], [line_no, line_data], ...]
# [[2, "UNH+SSDD1+ORDERS:D:03B:UN:EAN008'"], [3, "BGM+220+BKOD99+9'"], ...]

class Group
    attr_reader :name, :segments

    def initialize(name, lines, message_version, chars)
        @name = name
        @lines = lines
        @message_version = message_version
        @chars = chars
        @segments = []
        # Initial methods
        set_segments()
    end

    def set_segments()
        for line_no, line_data in @lines do
            params = [line_data, line_no, @message_version, @chars]
            @segments << SegmentFactory.new(*params).segment
        end
    end
end
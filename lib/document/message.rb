# Lines given in the form [[line_no, line_data], [line_no, line_data], ...]
# [[2, "UNH+SSDD1+ORDERS:D:03B:UN:EAN008'"], [3, "BGM+220+BKOD99+9'"], ...]

class Message
    attr_reader :version, :groups, :type
    attr_reader :header, :trailer

    def initialize(lines, interchange_version = '4', chars = DEFAULT_CHARS)
        @lines = lines
        @interchange_version = interchange_version
        @chars = chars
        @spec = nil
        @type = nil
        @version = nil
        @header = nil
        @trailer = nil
        @groups = []
        # Initial methods
        set_header()
        set_trailer()
        set_spec()
        set_groups()
    end

    def set_header()
        for line_no, line_data in @lines do
            if line_data.first(3) == 'UNH'
                params = [line_data, line_no, @interchange_version, @chars]
                @header = SegmentFactory.new(*params).segment
                @type = @header.message_type.data_value
                @version = @header.version_key
            end
        end
    end

    def set_trailer()
        for line_no, line_data in @lines do
            if line_data.first(3) == 'UNT'
                params = [line_data, line_no, @interchange_version, @chars]
                @trailer = SegmentFactory.new(*params).segment
            end
        end
    end

    def set_spec()
        @spec = $dictionary.message_structure_specification(@type, @version)
    end

    def set_groups()
        params = [@lines, @spec, @version, @chars]
        group_factory = GroupFactory.new(*params)
        @groups = group_factory.groups
    end
end
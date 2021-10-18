class UNHSegment < Segment
    attr_reader :message_type

    def initialize(raw, line_no, version = nil, chars = nil)
        super(raw, line_no, version, chars)
        @message_type = get_elements_by_code("0065").first
        @message_version = get_elements_by_code("0052").first
        @message_release = get_elements_by_code("0054").first
    end

    def version_key
        return @message_version.value + @message_release.value
    end
end
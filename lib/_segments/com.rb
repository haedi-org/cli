class COM < Line
    def initialize(data, line_no, version, chars)
        super(data, line_no, version, chars)
        # Push to elements
        push_elements([
            # (3148) Communication number
            @communication_number = define([1, 0], "3148"),
            # (3155) Communication channel qualifier
            @communication_channel_qualifier = define([1, 1], "3155", true)
        ])
    end
end
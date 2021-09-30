class UNT < Line
    def initialize(data, line_no, version, chars)
        super(data, line_no, version, chars)
        # Push to elements
        push_elements([
            # (0074) Number of segments in a message
            @number_of_segments = define([1, 0], "0074"),
            # (0062) Message reference number
            @message_reference = define([2, 0], "0062"),
        ])
    end
end
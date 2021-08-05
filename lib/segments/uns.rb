class UNS < Line
    def initialize(data, line_no, version, chars)
        super(data, line_no, version, chars)
        # Push to elements
        push_elements([
            # (0081) Section identification
            @section = define([1, 0], "0081", true),
        ])
    end
end
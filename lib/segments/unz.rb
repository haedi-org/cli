class UNZ < Line
    def initialize(data, line_no, version, chars)
        super(data, line_no, version, chars)
        # Push to elements
        push_elements([
            # (0036) Interchange control count
            @control_count = define([1, 0], "0036"),
            # (0020) Interchange control reference
            @control_reference = define([2, 0], "0020"),
        ])
    end
end
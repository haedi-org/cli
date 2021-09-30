class PCI < Line
    def initialize(data, line_no, version, chars)
        super(data, line_no, version, chars)
        # Push to elements
        push_elements([
            # (4233) Marking instructions, coded
            @marking_instructions = define([1, 0], "4233", true),
            # (7102) Shipping marks
            @shipping_marks = define([2, 0], "7102"),
        ])
    end
end
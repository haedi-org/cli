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

    def html
        coded = []
        typed = [[2, 0]]
        mssge = [[1, 0]]
        super(coded, typed, mssge)
    end

    def debug
        super
        @control_count.tap { |v| puts "Control count = " + v if v != nil }
        @control_reference.tap { |v| puts "Control ref = " + v if v != nil }
        puts "\n"
    end
end
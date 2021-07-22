class UNS < Line
    def initialize(data, line_no, version, chars)
        super(data, line_no, version, chars)
        # Push to elements
        push_elements([
            # (0081) Section identification
            @section = define([1, 0], "0081", true),
        ])
    end

    def html
        coded = []
        typed = []
        mssge = [[1, 0]]
        super(coded, typed, mssge)
    end

    def debug
        super
        @section.tap { |v| puts "Section = " + v.ref if v != nil }
        puts "\n"
    end
end
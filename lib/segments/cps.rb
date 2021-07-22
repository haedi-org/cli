class CPS < Line
    def initialize(data, line_no, version, chars)
        super(data, line_no, version, chars)
        # Push to elements
        push_elements([
            # (7164) Hierarchical id. number
            @hierarchical_number = define([1, 0], "7164"),
            # (7166) Hierarchical parent id.
            @hierarchical_parent = define([2, 0], "7166"),
            # (7075) Packaging level, coded
            @packaging_level = define([3, 0], "7075", true),
        ])
    end

    def html
        coded = [[3, 0]]
        typed = []
        mssge = [[1, 0], [2, 0]]
        super(coded, typed, mssge)
    end

    def debug
        super
        @hierarchical_number.tap { |v| puts "Number = " + v if v != nil }
        @hierarchical_parent.tap { |v| puts "Parent = " + v if v != nil }
        @packaging_level.tap { |v| puts "Level = " + v.ref if v != nil }
        puts "\n"
    end
end
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
end
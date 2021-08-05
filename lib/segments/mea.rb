class MEA < Line
    def initialize(data, line_no, version, chars)
        super(data, line_no, version, chars)
        # Push to elements
        push_elements([
            # (6311) Measurement purpose qualifier
            @purpose = define([1, 0], "6311", true),
            # (6313) Property measured, coded
            @attribute_measured = define([2, 0], "6313", true),
            # (6321) Measurement significance, coded
            @significance = define([2, 1], "6321", true),
            # (6155) Measurement attribute identification
            @attribute_id = define([2, 2], "6155"),
            # (6154) Measurement attribute
            @attribute = define([2, 3], "6154"),
            # (6411) Measure unit qualifier
            @unit = define([3, 0], "6411"),
            # (6314) Measurement value
            @value = define([3, 1], "6314"),
            # (6162) Range minimum
            @range_minimum = define([3, 2], "6162"),
            # (6152) Range maximum
            @range_maximum = define([3, 3], "6152"),
            # (6432) Significant digits
            @significant_digits = define([3, 4], "6432"),
        ])
    end
end
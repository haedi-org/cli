class CNT < Line
    def initialize(data, line_no, version, chars)
        super(data, line_no, version, chars)
        # Push to elements
        push_elements([
            # (6069) Control qualifier
            @control_qualifier = define([1, 0], "6069", true),
            # (6066) Control value
            @control_value = define([1, 1], "6066"),
            # (6411) Measure unit qualifier
            @measure_unit = define([1, 2], "6411"),
        ])
    end
end
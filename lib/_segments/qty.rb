class QTY < Line
    def initialize(data, line_no, version, chars)
        super(data, line_no, version, chars)
        # Push to elements
        push_elements([
            # (6063) Quantity qualifier
            @type = define([1, 0], "6063", true),
            # (6060) Quantity
            @quantity = define([1, 1], "6060"),
            # (6411) Measure unit qualifier
            @measurement_unit = define([1, 2], "6411"),
        ])
    end
end
class PRI < Line
    def initialize(data, line_no, version, chars)
        super(data, line_no, version, chars)
        # Push to elements
        push_elements([
            # (5125) Price qualifier
            @price_qualifier = define([1, 0], "5125", true),
            # (5118) Price
            @price = define([1, 1], "5118"),
            # (5375) Price type, coded
            @type = define([1, 2], "5375", true),
            # (5387) Price type qualifier
            @type_qualifier = define([1, 3], "5387", true),
            # (5284) Unit price basis
            @unit_price_basis = define([1, 4], "5284"),
            # (6411) Measure unit qualifier
            @measure_unit = define([1, 5], "6411"),
            # (5213) Sub-line price change, coded
            @sub_line_price_changed = define([2, 0], "5213", true),
        ])
    end
end
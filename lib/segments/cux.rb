class CUX < Line
    def initialize(data, line_no, version, chars)
        super(data, line_no, version, chars)
        # Push to elements
        push_elements([
            # (6347) Currency details qualifier
            @currency_details_qualifier = define([1, 0], "6347", true),
            # (6345) Currency, coded
            @currency = define([1, 1], "6345"),
            # (6343) Currency qualifier
            @currency_qualifier = define([1, 2], "6343", true),
            # (6348) Currency rate base
            @currency_rate_base = define([1, 3], "6348"),
            # (6347) Currency details qualifier
            @second_currency_details_qualifier = define([2, 0], "6347", true),
            # (6345) Currency, coded
            @second_currency = define([2, 1], "6345"),
            # (6343) Currency qualifier
            @second_currency_qualifier = define([2, 2], "6343", true),
            # (6348) Currency rate base
            @second_currency_rate_base = define([2, 3], "6348"),
            # (5402) Rate of exchange
            @rate_of_exchange = define([3, 0], "5402"),
            # (6341) Currency market exchange, coded
            @currency_markey_exchange = define([4, 0], "6341", true),
        ])
    end
end
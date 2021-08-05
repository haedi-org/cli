class MOA < Line
    def initialize(data, line_no, version, chars)
        super(data, line_no, version, chars)
        # Push to element
        push_elements([
            # (5025) Monetary amount type code qualifier
            @monetary_amount_qualifier = define([1, 0], "5025", true),
            # (5004) Monetary amount
            @monetary_amount = define([1, 1], "5004"),
            # (6345) Currency identification code
            @currency_code = define([1, 2], "6345"),
            # (6343) Currency type code qualifier
            @currency_code_qualifier = define([1, 3], "6343", true),
            # (4405) Status description code
            @status_code = define([1, 4], "4405", true),
                        # (5025) Monetary amount type code qualifier
            @monetary_amount_qualifier = define([1, 0], "5025", true),
            # (5004) Monetary amount
            @monetary_amount = define([1, 1], "5004"),
            # (6345) Currency identification code
            @currency_code = define([1, 2], "6345"),
            # (6343) Currency type code qualifier
            @currency_code_qualifier = define([1, 3], "6343", true),
            # (4405) Status description code
            @status_code = define([1, 4], "4405", true),
        ])
    end
end
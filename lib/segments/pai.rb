class PAI < Line
    def initialize(data, line_no, version, chars)
        super(data, line_no, version, chars)
        # Push to elements
        push_elements([
            # (4439) Payment conditions, coded
            @payment_conditions = define([1, 0], "4439", true),
            # (4431) Payment guarantee, coded
            @payment_guarantee = define([1, 1], "4431", true),
            # (4461) Payment means, coded
            @payment_means = define([1, 2], "4461", true),
            # (1131) Code list qualifier
            @code_list = define([1, 3], "1131", true),
            # (3055) Code list responsible agency, coded
            @agency = define([1, 4], "3055", true),
            # (4435) Payment channel, coded
            @payment_channel = define([1, 5], "4435", true)
        ])
    end
end
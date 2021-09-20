class PYT < Line
    def initialize(data, line_no, version, chars)
        super(data, line_no, version, chars)
        # Push to elements
        push_elements([
            # (4279) Payment terms type code qualifier
            @payment_terms_type = define([1, 0], "4279", true),
            # (4277) Payment terms description identifier
            @payment_terms_description_id = define([2, 0], "4277", true),
            # (1131) Code list qualifier
            @code_list = define([2, 1], "1131", true),
            # (3055) Code list responsible agency, coded
            @agency = define([2, 2], "3055", true),
            # (4276) Payment terms description
            @payment_terms_description = define([2, 3], "4276"),
            # (2475) Time reference code
            @time_reference_code = define([3, 0], "2475", true),
            # (2009) Terms time relation code
            @terms_time_relation_code = define([4, 0], "2009", true),
            # (2151) Period type code
            @period_type_code = define([5, 0], "2151", true),
            # (2152) Period count quantity
            @period_count_quantity = define([6, 0], "2152")
        ])
    end
end
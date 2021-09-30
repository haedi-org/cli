class ALC < Line
    def initialize(data, line_no, version, chars)
        super(data, line_no, version, chars)
        # Push to elements
        push_elements([
            # (5463) Allowance or charge qualifier
            @allowance_qualifier = define([1, 0], "5463", true),
            # (1230) Allowance or charge number
            @allowance_number = define([2, 0], "1230"),
            # (5189) Charge/allowance description, coded
            @allowance_description = define([2, 1], "5189", true),
            # (4471) Settlement, coded
            @settlement = define([3, 0], "4471", true),
            # (1227) Calculation sequence indicator, coded
            @calculation_sequence_indicator = define([4, 0], "1227", true),
            # (7161) Special services, coded
            @special_services = define([5, 0], "7161", true),
            # (1131) Code list qualifier
            @code_list = define([5, 1], "1131", true),
            # (3055) Code list responsible agency, coded
            @agency = define([5, 2], "3055", true),
            # (7160) Special service
            @special_service = [
                define([5, 3], "7160"),
                define([5, 4], "7160"),
            ]
        ].flatten)
    end
end
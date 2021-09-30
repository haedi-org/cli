class EQD < Line
    def initialize(data, line_no, version, chars)
        super(data, line_no, version, chars)
        # Push to elements
        push_elements([
            # (8053) Equipment qualifier
            @equipment_qualifier = define([1, 0], "8053", true),
            # (8260) Equipment identification number
            @equipment_id = define([2, 0], "8260"),
            # (1131) Code list qualifier
            @code_list = define([2, 1], "1131", true),
            # (3055) Code list responsible agency, coded
            @agency = define([2, 2], "3055", true),
            # (3207) Country, coded
            @country = define([2, 3], "3207"),
            # (8155) Equipment size and type identification
            @size_and_type_id = define([3, 0], "8155", true),
            # (1131) Code list qualifier
            @size_and_type_code_list = define([3, 1], "1131", true),
            # (3055) Code list responsible agency, coded
            @size_and_type_agency = define([3, 2], "3055", true),
            # (8154) Equipment size and type
            @size_and_type = define([3, 3], "8154"),
            # (8077) Equipment supplier, coded
            @supplier = define([4, 0], "8077", true),
            # (8249) Equipment status, coded
            @equipment_status = define([5, 0], "8249", true),
            # (8169) Full/empty indicator, coded
            @full_empty_indicator = define([6, 0], "8169", true)
        ])
    end
end
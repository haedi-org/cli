class PIA < Line
    def initialize(data, line_no, version, chars)
        super(data, line_no, version, chars)
        # Push to elements
        push_elements([
            # (4347) Product id. function qualifier
            @product_identifier = define([1, 0], "4347", true),
            # (7140) Item number
            @item_number = define([2, 0], "7140"),
            # (7143) Item number type, coded
            @item_number_type = define([2, 1], "7143", true),
            # (1131) Code list qualifier
            @code_list = define([2, 2], "1131", true),
            # (3055) Code list responsible agency, coded
            @agency = define([2, 3], "3055", true),
        ])
    end
end
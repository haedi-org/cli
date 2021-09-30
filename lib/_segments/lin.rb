class LIN < Line
    def initialize(data, line_no, version, chars)
        super(data, line_no, version, chars)
        # Push to elements
        push_elements([
            # (1082) Line item number
            @line_item_number = define([1, 0], "1082"),
            # (1229) Action request/notification, coded
            @action_request = define([2, 0], "1229", true),
            # (7140) Item number
            @item_id = define([3, 0], "7140"),
            # (7143) Item number type, coded
            @item_type = define([3, 1], "7143", true),
            # (1131) Code list qualifier
            @code_list = define([3, 2], "1131", true),
            # (3055) Code list responsible agency, coded
            @agency = define([3, 3], "3055", true),
        ])
    end
end
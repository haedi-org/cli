class ERC < Line
    def initialize(data, line_no, version, chars)
        super(data, line_no, version, chars)
        # Push to elements
        push_elements([
            # (9321) Application error identification
            @application_error_id = define([1, 0], "9321"),
            # (1131) Code list qualifier
            @code_list = define([1, 1], "1131", true),
            # (3055) Code list responsible agency, coded
            @agency = define([1, 2], "3055", true),
        ])
    end
end
class BGM < Line
    def initialize(data, line_no, version, chars)
        super(data, line_no, version, chars)
        # Push to elements
        push_elements([
            # (1001) Document/message name, coded
            @coded_message_name = define([1, 0], "1001", true),
            # (1131) Code list qualifier
            @code_list = define([1, 1], "1131", true),
            # (3055) Code list responsible agency, coded
            @agency = define([1, 2], "3055", true),
            # (1000) Document/message name
            @message_name = define([1, 3], "1000"),
            # (1004) Document/message number
            @message_number = define([2, 0], "1004"),
            # (1225) Message function, coded
            @message_function = define([3, 0], "1225", true),
            # (4343) Response type, coded
            @response_type = define([4, 0], "4343", true),
        ])
    end
end
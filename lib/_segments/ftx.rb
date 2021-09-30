class FTX < Line
    def initialize(data, line_no, version, chars)
        super(data, line_no, version, chars)
        # Push to elements
        push_elements([
            # (4451) Text subject qualifier
            @text_subject = define([1, 0], "4451", true),
            # (4453) Text function, coded
            @text_function  = define([2, 0], "4453", true),
            # (4441) Free text identification
            @free_text_desc = define([3, 0], "4441"),
            # (1131) Code list qualifier
            @code_list = define([3, 1], "1131", true),
            # (3055) Code list responsible agency, coded
            @agency = define([3, 2], "3055", true),
            # (4440) Free text
            @free_text = define([4], "4440"),
        ])
    end
end
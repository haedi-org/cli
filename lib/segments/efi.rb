class EFI < Line
    def initialize(data, line_no, version, chars)
        super(data, line_no, version, chars)
        # Push to elements
        push_elements([
    # TODO
    #        # (5245) Percentage qualifier
    #        @percentage_qualifier = define([1, 0], "5245", true),
    #        # (5482) Percentage
    #        @percentage = define([1, 1], "5482"),
    #        # (5249) Percentage basis, coded
    #        @percentage_basis = define([1, 2], "5249", true),
    #        # (1131) Code list qualifier
    #        @code_list = define([1, 3], "1131", true),
    #        # (3055) Code list responsible agency, coded
    #        @agency = define([1, 4], "3055", true)
        ])
    end
end
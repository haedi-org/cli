class SGP < Line
    def initialize(data, line_no, version, chars)
        super(data, line_no, version, chars)
        # Push to elements
        push_elements([
            # (8260) Equipment identification number
            @equipment_id = define([1, 0], "8260"),
            # (1131) Code list qualifier
            @code_list = define([1, 1], "1131", true),
            # (3055) Code list responsible agency, coded
            @agency = define([1, 2], "3055", true),
            # (3207) Country, coded
            @country = define([1, 3], "3207"),
            # (7224) Number of packages
            @number_of_packages = define([2, 0], "7224")
        ])
    end
end
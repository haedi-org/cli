class LOC < Line
    def initialize(data, line_no, version, chars)
        super(data, line_no, version, chars)
        # Push to elements
        push_elements([
            # (3227) Location function code qualifier
            @function = define([1, 0], "3227", true),
            # (3225) Place/location identification
            @identification = define([2, 0], "3225"),
            # (1131) Location code list qualifier
            @code_list = define([2, 1], "1131", true),
            # (3055) Code list responsible agency, coded
            @agency = define([2, 2], "3055", true),
            # (3244) Place/location
            @location = define([2, 3], "3244"),
        ])
    end
end
class GIR < Line
    def initialize(data, line_no, version, chars)
        super(data, line_no, version, chars)
        # Push to elements
        push_elements([
            # (7297) Set identification qualifier
            @set_identification_qualifier = define([1, 0], "7297", true),
	        # (7402) Identity number
            @identity_number = define([2, 0], "7402"),
	        # (7405) Identity number qualifier
            @identity_number_qualifier = define([2, 1], "7405", true),
	        # (4405) Status, coded
            @status = define([2, 2], "4405", true),
        ])
    end
end
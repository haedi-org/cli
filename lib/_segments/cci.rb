class CCI < Line
    def initialize(data, line_no, version, chars)
        super(data, line_no, version, chars)
        # Push to elements
        push_elements([
            # (7059) Property class, coded
            @property_class = define([1, 0], "7059", true),
            # (6313) Property measured, coded
            @property_measured = define([2, 0], "6313", true),
            # (6321) Measurement significance, coded
            @measurement_significance = define([2, 1], "6321", true),
            # (6155) Measurement attribute identification
            @measurement_attribute_id = define([2, 2], "6155", true),
            # (6154) Measurement attribute
            @measurement_attribute = define([2, 3], "6154"),
		    # (7037) Characteristic identification
            @characteristic_id = define([3, 0], "7037"),
		    # (1131) Code list qualifier
            @code_list_qualifier = define([3, 1], "1131", true),
		    # (3055) Code list responsible agency, coded
            @code_list_agency = define([3, 2], "3055", true),
		    # (7036) Characteristic
            @characteristic = [
                define([3, 3], "7036"),
                define([3, 4], "7036"),
            ].compact,
            # (4051) Characteristic relevance, coded
            @characteristic_relevance = define([4, 0], "4051", true),
        ].compact)
    end
end
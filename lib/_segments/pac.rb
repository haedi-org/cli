class PAC < Line
    def initialize(data, line_no, version, chars)
        super(data, line_no, version, chars)
        # Push to elements
        push_elements([
            # (7224) Number of packages
            @number_of_packages = define([1, 0], "7224"),
            # (7075) Packaging level, coded
            @packaging_level = define([2, 0], "7075", true),
            # (7233) Packaging related information, coded
            @packaging_information = define([2, 1], "7233", true),
            # (7073) Packaging terms and conditions, coded
            @packaging_terms = define([2, 2], "7073", true),
            # (7065) Type of packages identification
            @type_of_packages_id = define([3, 0], "7065"),
            # (1131) Code list qualifier
            @code_list = define([3, 1], "1131", true),
            # (3055) Code list responsible agency, coded
            @agency = define([3, 2], "3055", true),
            # (7064) Type of packages
            @type_of_packages = define([3, 3], "7064"),
            # (7077) Item description type, coded
            @item_description_type = define([4, 0], "7077", true),
            # (7064) Type of packages
            @type_of_packages_a = define([4, 1], "7064"),
            # (7143) Item number type, coded
            @item_number_type_a = define([4, 2], "7143", true),
            # (7064) Type of packages
            @type_of_packages_b = define([4, 3], "7064"),
            # (7143) Item number type, coded
            @item_number_type_b = define([4, 4], "7143", true),
            # (8395) Returnable package freight payment responsibility, coded
            @returnable_payment = define([5, 0], "8395", true),
            # (8393) Returnable package load contents, coded
            @returnable_contents = define([5, 1], "8393", true),
        ])
    end
end
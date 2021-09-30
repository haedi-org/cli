class GID < Line
    def initialize(data, line_no, version, chars)
        super(data, line_no, version, chars)
        # Push to elements
        push_elements([
            # (1496) Goods item number
            @goods_item_number = define([1, 0], "1496"),
            # (7224) Number of packages
            @number_of_packages_a = define([2, 0], "7224"),
            # (7065) Type of packages identification
            @type_of_packages_id_a = define([2, 1], "7065"),
            # (1131) Code list qualifier
            @code_list_a = define([2, 2], "1131", true),
            # (3055) Code list responsible agency, coded
            @agency_a = define([2, 3], "3055", true),
            # (7064) Type of packages
            @type_of_packages_a = define([2, 4], "7064"),
            # (7233) Packaging related information, coded
            @packaging_info_a = define([2, 5], "7233", true),
            # (7224) Number of packages
            @number_of_packages_b = define([3, 0], "7224"),
            # (7065) Type of packages identification
            @type_of_packages_id_b = define([3, 1], "7065"),
            # (1131) Code list qualifier
            @code_list_b = define([3, 2], "1131", true),
            # (3055) Code list responsible agency, coded
            @agency_b = define([3, 3], "3055", true),
            # (7064) Type of packages
            @type_of_packages_b = define([3, 4], "7064"),
            # (7233) Packaging related information, coded
            @packaging_info_b = define([3, 5], "7233", true),
            # (7224) Number of packages
            @number_of_packages_c = define([4, 0], "7224"),
            # (7065) Type of packages identification
            @type_of_packages_id_c = define([4, 1], "7065"),
            # (1131) Code list qualifier
            @code_list_c = define([4, 2], "1131", true),
            # (3055) Code list responsible agency, coded
            @agency_c = define([4, 3], "3055", true),
            # (7064) Type of packages
            @type_of_packages_c = define([4, 4], "7064"),
            # (7233) Packaging related information, coded
            @packaging_info_c = define([4, 5], "7233", true),
            # (7224) Number of packages
            @number_of_packages_d = define([5, 0], "7224"),
            # (7065) Type of packages identification
            @type_of_packages_id_d = define([5, 1], "7065"),
            # (1131) Code list qualifier
            @code_list_d = define([5, 2], "1131", true),
            # (3055) Code list responsible agency, coded
            @agency_d = define([5, 3], "3055", true),
            # (7064) Type of packages
            @type_of_packages_d = define([5, 4], "7064"),
            # (7233) Packaging related information, coded
            @packaging_info_d = define([5, 5], "7233", true),
            # (7224) Number of packages
            @number_of_packages_e = define([6, 0], "7224"),
            # (7065) Type of packages identification
            @type_of_packages_id_e = define([6, 1], "7065"),
            # (1131) Code list qualifier
            @code_list_e = define([6, 2], "1131", true),
            # (3055) Code list responsible agency, coded
            @agency_e = define([6, 3], "3055", true),
            # (7064) Type of packages
            @type_of_packages_e = define([6, 4], "7064"),
            # (7233) Packaging related information, coded
            @packaging_info_e = define([6, 5], "7233", true)
        ])
    end
end
class NAD < Line
    def initialize(data, line_no, version, chars)
        super(data, line_no, version, chars)
        # Push to elements
        push_elements([
            # (3035) Party qualifier
            @party_function = define([1, 0], "3035", true),
            # (3039) Party id. identification
            @party_id = define([2, 0], "3039"),
            # (1131) Code list qualifier
            @code_list = define([2, 1], "1131", true),
            # (3055) Code list responsibly agency 
            @agency = define([2, 2], "3055", true),
            # (3124) Name and address line (5 lines)
            @address = define([3], "3124"),
            # (3036) Party name (5 lines)
            @party_name = [
                define([4, 0], "3036"),
                define([4, 1], "3036"),
                define([4, 2], "3036"),
                define([4, 3], "3036"),
                define([4, 4], "3036"),
            ].compact,
            # (3045) Party name format, coded
            @party_format = define([4, 5], "3045", true),
            # (3042) Street and number/p.o. box (4 lines)
            @street = define([5], "3042"),
            # (3164) City name
            @city = define([6, 0], "3164"),
            # (3229) Country sub-entity identification
            @region = define([7, 0], "3229"),
            # (3251) Postcode identification
            @postcode = define([8, 0], "3251"),
            # (3207) Country, coded
            @country = define([9, 0], "3207", true),
        ].flatten)
    end
    
    # Example:
    # NAD+BY+++Customer's name+High Street+Example Town++23436+xx'

    def html
        codes = [[1, 0], [4, 5], [9, 0]]
        typed = [[2, 0],
                 [3, 0], [3, 1], [3, 2], [3, 3], [3, 4],
                 [4, 0], [4, 1], [4, 2], [4, 3], [4, 4],
                 [5, 0], [5, 1], [5, 2], [5, 3],
                 [6, 0], [7, 0], [8, 0]
                ]
        mssge = [[2, 1], [2, 2]]
        super(codes, typed, mssge)
    end

    def debug
        super
        @party_function.tap { |v| puts "Function = " + v.ref if v != nil }
        @party_id.tap { |v| puts "ID = " + v if v != nil }
        @code_list.tap { |v| puts "Code list = " + v.ref if v != nil }
        @agency.tap { |v| puts "Agency = " + v.ref if v != nil }
        puts "\n"
    end
end
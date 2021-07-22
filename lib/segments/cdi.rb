class CDI < Line
    def initialize(data, line_no, version, chars)
        super(data, line_no, version, chars)
        # Push to qualifier
        push_elements([
            # (7001) Physical or logical state qualifier
            @state_qualifier = define([1, 0], "7001", true),
            # (7007) Physical or logical state, coded
            @state_coded = define([2, 0], "7007", true),
            # (1131) Code list qualifier
            @code_list = define([2, 1], "1131", true),
            # (3055) Code list responsible agency, coded
            @agency = define([2, 2], "3055", true),
            # (7006) Physical or logical state
            @state = define([2, 3], "7006"),
        ])
    end

    def html
        coded = [[1, 0], [2, 0]]
        typed = [[2, 3]]
        mssge = [[2, 1], [2, 2]]
        super(coded, typed, mssge)
    end

    def debug
        super
        puts "\n"
    end
end
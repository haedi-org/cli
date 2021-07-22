class ALI < Line
    def initialize(data, line_no, version, chars)
        super(data, line_no, version, chars)
        # Push to elements
        push_elements([
            # (3239) Country of origin, coded
            @country = define([1, 0], "3239", true),
            # (9213) Type of duty regime, coded
            @duty_regime = define([2, 0], "3239", true),
            # (4183) Special conditions, coded (5 lines)
            @special_conditions = [
                define([3, 0], "4183"),
                define([4, 0], "4183"),
                define([5, 0], "4183"),
                define([6, 0], "4183"),
                define([7, 0], "4183"),
            ].compact,
        ].flatten)
    end

    def html
        coded = [[1, 0], [2, 0], [3, 0], [4, 0], [5, 0], [6, 0], [7, 0]]
        super(coded)
    end

    def debug
        super
        puts "\n"
    end
end
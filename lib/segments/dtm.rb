class DTM < Line
    attr_reader :date
    attr_reader :qualifier

    def initialize(data, line_no, version, chars)
        super(data, line_no, version, chars)
        # Push to elements
        push_elements([
            # (2005) Date/time/period qualifier
            @qualifier = define([1, 0], "2005", true),
            # (2380) Date/time/period
            @date = define([1, 1], "2380"),
            # (2379) Date/time/period format qualifier
            @format = define([1, 2], "2379", true),
        ])
        # Set date reference
        @date.set_interpreted_data(interpret_date(@date.value, @format.value))
    end

    def interpret
        return interpret_date(@date.value, @format.value)
    end
end
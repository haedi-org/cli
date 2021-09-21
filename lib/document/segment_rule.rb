class SegmentRule
    def initialize(data)
        @data = data
    end

    def mandatory?
        return false unless @data.key?("m/c")
        return @data["m/c"] == "M"
    end

    def conditional?
        return true unless @data.key?("m/c")
        return @data["m/c"] == "C"
    end

    def alphanumeric?
        return true unless @data.key?("repr")
        return @data["repr"].split("..")[0] == "an"
    end

    def numeric?
        return false unless @data.key?("repr")
        return @data["repr"].split("..")[0] == "n"
    end

    def max_length?
        return 512 unless @data.key?("repr")
        return @data["repr"].split("..")[1].to_i
    end
end
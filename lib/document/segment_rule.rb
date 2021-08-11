class SegmentRule
    def initialize(data)
        @data = data
    end

    def mandatory?
        return true unless @data.key?("m/c")
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

    def max_length?
        return true unless @data.key?("repr")
        return @data["repr"].split("..")[1].to_i
    end
end
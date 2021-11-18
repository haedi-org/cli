class Rule
    def initialize(data, inherited_m_c = "C")
        @data = data
        @inherited_m_c = inherited_m_c
    end

    def describe_length
        str = ''
        str += '=' if self.fixed_length?
        str += '<' if self.variable_length?
        str += length.to_s if self.fixed_length?
        str += (length + 1).to_s if self.variable_length?
        return str
    end

    def describe_symbols
        str = ''
        str += 'alphanumeric' if self.alphanumeric?
        str += 'numeric' if self.numeric?
        return str
    end

    def check_length(value)
        value = '' if value == nil
        if self.fixed_length?
            return value.length == length()
        else
            return value.length <= length()
        end
    end

    def check_symbols(value)
        value = '' if value == nil
        return false if self.numeric? and (!value.is_numeric?)
        return true
    end

    def mandatory?
        return false if @inherited_m_c == "C"
        return false unless @data.key?("m/c")
        return @data["m/c"] == "M"
    end

    def conditional?
        return true if @inherited_m_c == "C"
        return true unless @data.key?("m/c")
        return @data["m/c"] == "C"
    end

    def alphanumeric?
        return true unless @data.key?("repr")
        return split_repr[0] == "an"
    end

    def numeric?
        return false unless @data.key?("repr")
        return split_repr[0] == "n"
    end

    def length
        return 512 unless @data.key?("repr")
        return split_repr[1].to_i
    end

    def fixed_length?
        return false unless @data.key?("repr")
        return (!@data["repr"].include?(".."))
    end

    def variable_length?
        return true unless @data.key?("repr")
        return @data["repr"].include?("..")
    end

    def split_repr
        return nil unless @data.key?("repr")
        @data["repr"].gsub("..", "").tap do |r|
            return r.include?("an") ? [r[0, 2], r[2..-1]] : [r[0, 1], r[1..-1]]
        end
    end
end
module EDIFACT
    DEFAULT_LENGTH = 512
    DEFAULT_M_C = "C"

    class Rule
        def initialize(data, inherited_m_c = DEFAULT_M_C)
            # Define values from given arguments
            @data, @inherited_m_c = data, inherited_m_c
        end

        def random_string
            # Generate a valid string length
            l = self.fixed_length? ? self.length : 1 + rand(self.length)
            # Define charset
            s = self.numeric? ? [*'0'..'9'] : [*'a'..'z', *'A'..'Z', *'0'..'9']
            # Return a string built as a joined list of random characters
            return (Array.new(l) { s.sample }).join
        end

        def describe_length
            str = ''
            str += '=' if self.fixed_length?
            str += '<' if self.variable_length?
            str += self.length.to_s if self.fixed_length?
            str += (self.length + 1).to_s if self.variable_length?
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

        # UN/EDIFACT         EDIFICE
        # M (Mandatory)   => M (Mandatory)
        # C (Conditional) => R (Required)
        # C (Conditional) => D (Depending)
        # C (Conditional) => A (Advised)
        # C (Conditional) => O (Optional)
        # C (Conditional) => N (Not Used)

        def m_c
            return @data["m/c"] if @data.key?("m/c")
            return @data["m_c"] if @data.key?("m_c")
            return @inherited_m_c
        end

        def mandatory?
            return m_c == "M"
        end

        def conditional?
            return m_c != "M"
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
            return DEFAULT_LENGTH unless @data.key?("repr")
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
                if r.include?("an")
                    return [r[0, 2], r[2..-1]]
                else
                    return [r[0, 1], r[1..-1]]
                end
            end
        end
    end
end
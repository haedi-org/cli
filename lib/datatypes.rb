ALPHABET = *("A".."Z")
NUMBERS = *("0".."9")

class String
    def is_alphanumeric?
        return true
        #for char in self.upcase.chars do
        #    return false unless (ALPHABET + NUMBERS).include?(char)
        #end
        #return true
    end

    def is_numeric?
        return true if Float(self) rescue false
    end

    def is_datetime?
        check = DateTime.parse(self) rescue nil
        return check != nil
    end

    def is_sscc?
        return false unless self.is_number?
        return false unless self.length == 18
        # Split into data and check digit
        data, given_check_digit = self[0, 17].chars, self[17, 1].to_i
        # Calculate check digit
        sum = data.map.with_index { |c, i| c.to_i * (i % 2 == 0 ? 3 : 1) }.sum
        expected_check_digit = 10 - (sum % 10)
        # Return bool
        # puts [self, given_check_digit, expected_check_digit].inspect
        return given_check_digit == expected_check_digit
    end

    def is_gsin?
        return (('0' * 1) + self).is_sscc?
    end

    def is_gtin_14?
        return (('0' * 4) + self).is_sscc?
    end

    def is_gtin_13?
        return (('0' * 5) + self).is_sscc?
    end

    def is_gtin_12?
        return (('0' * 6) + self).is_sscc?
    end

    def is_gtin_8?
        return (('0' * 10) + self).is_sscc?
    end

    def is_gs1_id?
        return case self.length
            when 18
                self.is_gsin?
            when 14
                self.is_gtin_14?
            when 13
                self.is_gtin_13?
            when 12
                self.is_gtin_12?
            when 8
                self.is_gtin_8?
            else
                false
        end
    end

    def is_vin?
        return true
    end
end
class String

    ALPHABET = *("A".."Z")
    NUMBERS = *("0".."9")

    def is_alphanumeric?
        for char in self.upcase.chars do
            return false unless (ALPHABET + NUMBERS).include?(char)
        end
        return true
    end

    def is_numeric?
        return true if Float(self) rescue false
    end

    def is_datetime?
        check = DateTime.parse(self) rescue nil
        return check != nil
    end

    def is_gtin_18?
        return false unless self.is_number?
        return false unless self.length == 18
        # Split into data and check digit
        data, given_check_digit = self[0, 17].chars, self[17, 1].to_i
        # Calculate check digit
        sum = data.map.with_index { |c, i| c.to_i * (i % 2 == 0 ? 3 : 1) }.sum
        expected_check_digit = 10 - (sum % 10)
        # Return bool
        return given_check_digit == expected_check_digit
    end

    def is_gsin?
        return (('0' * 1) + self).is_gtin_18?
    end

    def is_gtin_14?
        return (('0' * 4) + self).is_gtin_18?
    end

    def is_gtin_13?
        return (('0' * 5) + self).is_gtin_18?
    end

    def is_gtin_12?
        return (('0' * 6) + self).is_gtin_18?
    end

    def is_gtin_8?
        return (('0' * 10) + self).is_gtin_18?
    end

    def is_sscc?
        return self.is_gtin_18?
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
    
    VIN_ILLEGAL_CHARACTERS = ['I', 'O', 'Q']

    VIN_WEIGHTS = [8, 7, 6, 5, 4, 3, 2, 10, 0, 9, 8, 7, 6, 5, 4, 3, 2]

    VIN_TRANSLITERATION_MAP = {
        'A' => 1, 'B' => 2, 'C' => 3, 'D' => 4, 'E' => 5, 'F' => 6, 
        'G' => 7, 'H' => 8, 'J' => 1, 'K' => 2, 'L' => 3, 'M' => 4, 
        'N' => 5, 'P' => 7, 'R' => 9, 'S' => 2, 'T' => 3, 'U' => 4, 
        'V' => 5, 'W' => 6, 'X' => 7, 'Y' => 8, 'Z' => 9,
    }

    def is_vin?
        # Check for correct length
        return false unless self.length == 17
        # Check string is alphanumeric
        return false unless self.is_alphanumeric?
        # Check for illegal characters (i.e. 'I', 'O', and 'Q')
        for illegal_char in VIN_ILLEGAL_CHARACTERS do
            return false if self.upcase.include?(illegal_char)
        end
        # Step 1: Transliterate
        values = []
        for char in self.upcase.chars do
            if ('A'..'Z').to_a.include?(char)
                values << VIN_TRANSLITERATION_MAP[char]
            else
                values << char.to_i
            end
        end
        # Step 2: Compute weighted products
        weighted_values = values.map.with_index do |value, index|
            value * VIN_WEIGHTS[index]
        end
        # Step 3: Compute remainder
        remainder = (weighted_values.sum % 11).to_s
        remainder = 'X' if remainder == '10'
        # Step 4: Compare remainder to check digit (the 9th character)
        check_digit = self.chars[8]
        return remainder == check_digit
    end

    ACRN_ILLEGAL_CHARACTERS = ["O", "I"]

    def is_acrn?
        # Check length is equal to 2
        return false unless self.length == 2
        # Check string is alphanumeric
        return false unless self.is_alphanumeric?
        # Check string does not contain illegal characters
        for illegal_char in ACRN_ILLEGAL_CHARACTERS do
            return false if self.upcase.include?(illegal_char)
        end
        return true
    end

    def is_isbn?
        # Ignore dashes
        str = self.gsub('-', '')
        return str.is_isbn_10? if str.length == 10
        return str.is_isbn_13? if str.length == 13
        return false
    end

    def is_isbn_10?
        # Ignore dashes
        str = self.gsub('-', '')
        # Check length
        return false unless (str.length == 10)
        # Check number
        return false unless str[0, 9].is_numeric?
        # Split data
        digits, given_check_digit = str.chars[0, 9], str.chars[9]
        # Step 1: Apply weights
        digits.map!.with_index do |digit, index|
            digit.to_i * (10 - index)
        end
        # Step 2: Find check digit as modulus - (sum % modulus)
        expected_check_digit = (11 - (digits.sum % 11)).to_s
        expected_check_digit = 'X' if expected_check_digit == '10'
        # Step 3: Compare remainder with check digit
        return expected_check_digit == given_check_digit
    end

    def is_isbn_13?
        # Ignore dashes
        str = self.gsub('-', '')
        # Check length
        return false unless (str.length == 13)
        # Check number
        return false unless str.is_numeric?
        # Split data
        digits, given_check_digit = str.chars[0, 12], str.chars[12]
        # Step 1: Apply weights
        digits.map!.with_index do |digit, index|
            digit.to_i * ((index % 2 == 0) ? 1 : 3)
        end
        # Step 2: Find check digit as modulus - (sum % modulus)
        expected_check_digit = (10 - (digits.sum % 10)).to_s
        expected_check_digit = '0' if expected_check_digit == '10'
        # Step 3: Compare remainder with check digit
        return expected_check_digit == given_check_digit
    end

end
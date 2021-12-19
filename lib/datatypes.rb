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
        # Check numeric
        return false unless self.is_number?
        # Check for correct length
        return false unless self.length == 18
        # Split into data and check digit
        digits, given_check_digit = self[0, 17].chars, self[17, 1].to_i
        # Step 1: Apply weights
        digits.map!.with_index do |digit, index|
            digit.to_i * ((index % 2 == 0) ? 3 : 1)
        end
        # Step 2: Find check digit as modulus - (sum % modulus)
        expected_check_digit = 10 - (digits.sum % 10)
        # Step 3: Compare check digit
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

    ISO_6346_TRANSLITERATION_MAP = {
        'A' => 10, 'B' => 12, 'C' => 13, 'D' => 14, 'E' => 15, 'F' => 16,
        'G' => 17, 'H' => 18, 'I' => 19, 'J' => 20, 'K' => 21, 'L' => 23,
        'M' => 24, 'N' => 25, 'O' => 26, 'P' => 27, 'Q' => 28, 'R' => 29,
        'S' => 30, 'T' => 31, 'U' => 32, 'V' => 34, 'W' => 35, 'X' => 36,
        'Y' => 37, 'Z' => 38,
    }

    ISO_6346_CATEGORY_IDS = ['U', 'J', 'Z']

    def is_iso_6346?
        # Check for correct length
        return false unless self.length == 11
        # Check 4th character is a valid category identifier
        return false unless ISO_6346_CATEGORY_IDS.include?(self.chars[3])
        # Step 1: Transliterate
        values = []
        for char in self.upcase.chars[0, 10] do
            if ('A'..'Z').to_a.include?(char)
                values << ISO_6346_TRANSLITERATION_MAP[char]
            else
                values << char.to_i
            end
        end
        # Step 2: Multiply by n^index
        values = values.map.with_index do |value, index|
            value * (2 ** index)
        end
        # Step 3: Compute check digit
        expected_check_digit = values.sum - (11 * (values.sum / 11).floor)
        # Step 4: Compare remainder to check digit (the 11th character)
        given_check_digit = self.chars[10]
        return given_check_digit == expected_check_digit.to_s
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
        str = self.gsub('-', '').gsub(' ', '')
        return str.is_isbn_10? if str.length == 10
        return str.is_isbn_13? if str.length == 13
        return false
    end

    def is_isbn_10?
        # Ignore dashes
        str = self.gsub('-', '').gsub(' ', '')
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
        str = self.gsub('-', '').gsub(' ', '')
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

    ISSN_WEIGHTS = [8, 7, 6, 5, 4, 3, 2]

    def is_issn?
        # Ignore dashes
        str = self.gsub('-', '').gsub(' ', '')
        # Check length
        return false unless (str.length == 8)
        # Check number
        return false unless str.is_numeric?
        # Split data
        digits, given_check_digit = str.chars[0, 7], str.chars[7]
        # Step 1: Apply weights
        digits.map!.with_index do |digit, index|
            digit.to_i * ISSN_WEIGHTS[index]
        end
        # Step 2: Find check digit as modulus - (sum % modulus)
        expected_check_digit = (11 - (digits.sum % 11)).to_s
        expected_check_digit = 'X' if expected_check_digit == '10'
        expected_check_digit = '0' if expected_check_digit == '11'
        # Step 3: Compare remainder with check digit
        return expected_check_digit == given_check_digit
    end

    def is_ismn?
        # Ignore dashes and spaces
        str = self.gsub('-', '').gsub(' ', '')
        return str.is_ismn_10? if str.length == 10
        return str.is_ismn_13? if str.length == 13
        return false
    end

    def is_ismn_10?
        # Ignore dashes and spaces
        str = self.gsub('-', '').gsub(' ', '')
        # Replace leading 'M' with '0'
        str = str.gsub('M', '0')
        # Prefix with '979' to become ISMN-13
        return ('979' + str).is_ismn_13?
    end

    def is_ismn_13?
        # Ignore dashes and spaces
        str = self.gsub('-', '').gsub(' ', '')
        # Check length
        return false unless (str.length == 13)
        # Check number
        return false unless str.is_numeric?
        # Check prefix is '9790'
        return false unless str[0, 4] == '9790'
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
class String

    ISO_6346_TRANSLITERATION_MAP = {
        'A' => 10, 'B' => 12, 'C' => 13, 'D' => 14, 'E' => 15, 'F' => 16,
        'G' => 17, 'H' => 18, 'I' => 19, 'J' => 20, 'K' => 21, 'L' => 23,
        'M' => 24, 'N' => 25, 'O' => 26, 'P' => 27, 'Q' => 28, 'R' => 29,
        'S' => 30, 'T' => 31, 'U' => 32, 'V' => 34, 'W' => 35, 'X' => 36,
        'Y' => 37, 'Z' => 38,
    }

    ISO_6346_CATEGORY_IDS = ['U', 'J', 'Z']

    def is_iso_6346_container_code?
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

    def is_iso_6346_size_and_type?
        # Check for correct length
        return true if self.length == 4
    end

end

def parse_iso_6346_size_type(code)
    # Ensure given code is ISO 6346 compliant
    return nil unless code.is_iso_6346_size_and_type?
    data = $dictionary.code_list_lookup("6346")
    # Return nil if no ISO 6346 information is present
    return nil if data.blank?
    data = data["SIZETYPE"]
    # Breakdown and parse code
    l_code, h_w_code, t_code = code[0, 1], code[1, 1], code[2, 2]
    l = data["length"].key?(l_code  ) ? data["length"][l_code  ] : nil
    h = data["height"].key?(h_w_code) ? data["height"][h_w_code] : nil
    w = data["width" ].key?(h_w_code) ? data["width" ][h_w_code] : nil
    t = data["type"  ].key?(t_code  ) ? data["type"  ][t_code  ] : nil
    # Return nil if any values are not represented
    return nil unless [l, h, w, t].compact.length == 4
    # Return name and description of size and type
    return {
        "name" => data["common"].key?(code) ? data["common"][code] : code,
        "desc" => "#{t} (#{l} × #{h} × #{w})"
    }
end
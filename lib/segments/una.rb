class UNA < Line
    def initialize(data, line_no, version, chars = nil)
        @version = version
        @line_no = line_no
        @raw = data
        @data = [["UNA"]]
        @elements = []
        @tag = tag
        # Push to elements
        push_elements([
            # (UNA1) Component data element separator
            @component_element_seperator = lookup("UNA1", @raw[3]),
            # (UNA2) Data element separator
            @data_element_seperator = lookup("UNA2", @raw[4]),
            # (UNA3) Decimal mark
            @decimal_mark = lookup("UNA3", @raw[5]),
            # (UNA4) Release character
            @release_character = lookup("UNA4", @raw[6]),
            # (UNA5) Repetition separator
            @repetition_seperator = lookup("UNA5", @raw[7]),
            # (UNA6) Segment terminator
            @segment_terminator = lookup("UNA6", @raw[8]),
        ])
        # Assign chars
        @chars = punctuation
    end

    def html
        clr, fwt = "#2B2B2B", "bold"
        style = "color: #{clr}; font-weight: #{fwt}"
        a = "<b style='#{style}'>#{@raw[0, 3]}</b>"
        clr, fwt = "#D512E2", "bold"
        style = "color: #{clr}; font-weight: #{fwt}"
        b = "<b style='#{style}'>#{@raw[3..-1]}</b>"
        return a + b
    end

    def lookup(element_code, data_value)
        csv = csv_reference(EDIFACT_STRING_ADVICE_PATH, element_code)
        unless csv == nil
            element_title = csv[1]
            data_description = csv[2]
            return Element.new(
                [0, 0], element_code, element_title, 
                data_value, "", data_description, false
            )
        else
            return Element.new(
                [0, 0], element_code, "", data_value, "", "", false
            )
        end
    end

    def punctuation
        return Punctuation.new(
            @component_element_seperator.value,
            @data_element_seperator.value,
            @decimal_mark.value,
            @release_character.value,
            @segment_terminator.value
        )
    end
end
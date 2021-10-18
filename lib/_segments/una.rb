class UNA < Line
    def initialize(data, line_no, version, chars = nil)
        @version = version
        @line_no = line_no
        @raw = data
        @data = [["UNA"]]
        @tag = assign_tag()
        @rules = assign_rules()
        @elements = []
        # Push to elements
        push_elements([
            # (UNA1) Component data element separator
            @component_element_separator = lookup("UNA1", @raw[3]),
            # (UNA2) Data element separator
            @data_element_separator = lookup("UNA2", @raw[4]),
            # (UNA3) Decimal mark
            @decimal_mark = lookup("UNA3", @raw[5]),
            # (UNA4) Release character
            @release_character = lookup("UNA4", @raw[6]),
            # (UNA5) Repetition separator
            @repetition_separator = lookup("UNA5", @raw[7]),
            # (UNA6) Segment terminator
            @segment_terminator = lookup("UNA6", @raw[8]),
        ])
        # Assign chars
        @chars = punctuation
        @valid = true
    end

    def lookup(element_code, data_value)
        return Element.new(
            self, [0, 0, element_code[3]], element_code, 
            :data_value => data_value, :version => version
        )
    end

    def punctuation
        return Punctuation.new(
            @component_element_separator.value,
            @data_element_separator.value,
            @decimal_mark.value,
            @release_character.value,
            @segment_terminator.value
        )
    end
end
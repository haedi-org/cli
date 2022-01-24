module EDIFACT
    DEFAULT_SEGMENT_TERMINATOR = '\''

    Punctuation = Struct.new(
        :component_element_separator,
        :data_element_separator,
        :decimal_mark,
        :release_character,
        :repetition_separator,
        :segment_terminator
    )

    DEFAULT_CHARS = Punctuation.new(
        ':', '+', '.', '?', ' ', DEFAULT_SEGMENT_TERMINATOR
    )
end
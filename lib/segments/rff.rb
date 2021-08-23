class RFF < Line
    attr_reader :reference
    attr_reader :reference_number

    def initialize(data, line_no, version, chars)
        super(data, line_no, version, chars)
        # Push to element
        push_elements([
            # (1153) Reference qualifier
            @reference = define([1, 0], "1153", true),
            # (1154) Reference number
            @reference_number = define([1, 1], "1154"),
            # (1156) Line number
            @line_number = define([1, 2], "1156"),
            # (4000) Reference version number
            @reference_version = define([1, 3], "4000"),
        ])
    end
end
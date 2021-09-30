class EFI < Line
    def initialize(data, line_no, version, chars)
        super(data, line_no, version, chars)
        # Push to elements
        push_elements([
            # (1508) File name
            @file_name = define([1, 0], "1508"),
            # (7008) Item description
            @item_description = define([1, 1], "7008"),
            # (1516) File format
            @file_format = define([2, 0], "1516"),
            # (1056) Version
            @file_version = define([2, 1], "1056"),
            # (1503) Data format, coded	
            @data_format_qualifier = define([2, 2], "1503", true),
            # (1502) Data format
            @data_format = define([2, 3], "1502"),
            # (1050) Sequence number
            @sequence_number = define([3, 0], "1050")
        ])
    end
end
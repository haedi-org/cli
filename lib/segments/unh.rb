class UNH < Line
    attr_reader :message_reference
    attr_reader :message_type
    attr_reader :message_version
    attr_reader :controlling_agency
    attr_reader :association_code

    def initialize(data, line_no, version, chars)
        super(data, line_no, version, chars)
        # Push to elements
        push_elements([
            # (0052) Message version number
            @message_version = format_version,
            # (0062) Message reference number
            @message_reference = define([1, 0], "0062"),
            # (0065) Message type
            @message_type = define([2, 0], "0065", true, @message_version.ref),
            # (0051) Controlling agency, coded
            @controlling_agency = define([2, 3], "0051", true, @message_version.ref),
            # (0057) Association assigned code
            @association_code = define([2, 4], "0057", true, @message_version.ref),
        ])
    end

    def html
        coded = []
        typed = [[1, 0]]
        mssge = [[2, 0], [2, 1], [2, 2], [2, 3], [2, 4]]
        super(coded, typed, mssge)
    end
    
    def format_version
        # Get definition information
        codes = ["0052", "0054"]
        definitions = codes.map { |code| define_element_code(code).definition }
        # (0052) Message version number
        @message_version_number = data_at(@line_no, 2, 1)
        # (0054) Message release number
        @message_release_number = data_at(@line_no, 2, 2)
        # Return version struct
        return Version.new(
            @message_version_number, 
            @message_release_number, 
            @message_version_number +
            @message_release_number,
            codes.join("/"),
            definitions.join("/")
        )
    end

    def debug
        super
        puts "Message type = " + @message_type.ref
        puts "Message description = " + @message_type.desc
        puts "Message version = " + @message_version.ref
        puts "\n"
    end
end
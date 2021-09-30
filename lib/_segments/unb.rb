class UNB < Line
    attr_reader :sender_id
    attr_reader :recipient_id
    attr_reader :preparation_date
    attr_reader :preparation_time
    
    def initialize(data, line_no, version, chars)
        super(data, line_no, version, chars)
        # Push to elements
        push_elements([
            # (0001) Syntax identifier
            @syntax_identifier = define([1, 0], "0001", true),
            # (0002) Syntax version number
            @syntax_version = define([1, 1], "0002", true),
            # (0080) Service code list directory version number
            @code_list_version = define([1, 2], "0080"),
            # (0133) Character encoding, coded
            @character_encoding = define([1, 3], "0133", true),
            # (0004) Interchange sender identification
            @sender_id = define([2, 0], "0004"),
            # (0007) Identification code qualifier
            @sender_id_qualifier = define([2, 1], "0007", true),
            # (0008) Interchange sender internal identification
            @sender_internal_id = define([2, 2], "0008"),
            # (0042) Interchange sender internal sub-identification
            @sender_internal_sub_id = define([2, 3], "0042"),
            # (0010) Interchange recipient identification
            @recipient_id = define([3, 0], "0010"),
            # (0007) Identification code qualifier
            @recipient_id_qualifier = define([3, 1], "0007", true),
            # (0014) Interchange recipient internal identification
            @recipient_internal_id = define([3, 2], "0014"),
            # (0046) Interchange recipient internal sub-identification
            @recipient_internal_sub_id = define([3, 3], "0046"),
            # (0017) Date of preparation - YYMMDD (101)
            @preparation_date = define([4, 0], "0017"),
            # (0019) Time of preparation - HHMM (401)
            @preparation_time = define([4, 1], "0019"),
            # (0020) Interchange control reference
            @control_reference = define([4, 2], "0020"),
            # (0022) Recipient reference/password
            @recipient_reference = define([5, 0], "0022"),
            # (0025) Recipient reference/password qualifier
            @recipient_reference_qualifier = define([5, 1], "0025", true),
            # (0026) Application reference
            @application_reference = define([5, 2], "0026"),
            # (0029) Processing priority code
            @priority_code = define([5, 3], "0029", true),
            # (0031) Acknowledgement request
            @acknowledgement_request = define([5, 4], "0031", true),
            # (0032) Interchange agreement identifier
            @agreement_identifier = define([5, 5], "0032"),
            # (0035) Test indicator
            @test_indicator = define([5, 6], "0035", true),
        ])
        @preparation_date.set_interpreted_data(interpret)
    end

    # Example (D13A):
    # UNB+UNOC:3+O0013000089TEVES+O0013009096BIP-XPRS-AI-P+170308:2018+000000003'

    def interpret
        return nil if @preparation_date.blank?
        return nil if @preparation_date.value.blank?
        return case @preparation_date.value.length
            when 6; interpret_date(@preparation_date.value, "101")
            when 8; interpret_date(@preparation_date.value, "102")
            else; @preparation_date
        end
    end

    def time
        return nil if @preparation_time.blank?
        return nil if @preparation_time.value.blank?
        return interpret_date(@preparation_time.value, "401")
    end
end
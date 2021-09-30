class GIN < Line
    def initialize(data, line_no, version, chars)
        super(data, line_no, version, chars)
        # Push to elements
        push_elements([
            # (7405) Identity number qualifier
            @identity_qualifier = define([1, 0], "7405", true),
            # (7402) Identity number
            @identity_range = [
                define([2, 0], "7402"),
                define([2, 1], "7402"),
            ],
        ].flatten)
        # Validate identity number
        validate_identity_numbers()
    end

    def validate_identity_numbers()
        for identity_number in @identity_range do
            if identity_number.is_a?(Element)
                validity = case @identity_qualifier.value
                    when 'BJ' # GS1 serial shipping container code
                        identity_number.value.is_sscc?
                    else
                        true
                end
                identity_number.set_validity(
                    validity ? true : InvalidSSCCError.new
                )
            end
        end
    end
end
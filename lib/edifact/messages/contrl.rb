module EDIFACT
    class CONTRLMessage < Message
        attr_reader :interchange_action, :interchange_syntax_error
        attr_reader :message_action, :message_syntax_error
        attr_reader :segment_position_in_body, :segment_syntax_error

        def initialize(
            lines, interchange_version = '4', chars = DEFAULT_CHARS, 
            application_reference = nil)
            super(lines, interchange_version, chars, application_reference)
            set_values
        end

        def set_values
            for group in @groups do
                # Interchange
                uci = group.get_segments_by_tag("UCI").first
                unless uci.blank?
                    @interchange_action = uci.action
                    @interchange_syntax_error = uci.syntax_error
                end
                # Message
                ucm = group.get_segments_by_tag("UCM").first
                unless ucm.blank?
                    @message_action = ucm.action
                    @message_syntax_error = ucm.syntax_error
                end
                # Segment
                ucs = group.get_segments_by_tag("UCS").first
                unless ucs.blank?
                    @segment_position_in_body = ucs.segment_position_in_body
                    @segment_syntax_error = ucs.syntax_error
                end
            end
        end
    end
end
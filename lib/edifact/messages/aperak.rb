module EDIFACT
    class APERAKMessage < Message
        attr_reader :application_error_id
        attr_reader :responsible_agency, :code_list_qualifier

        def initialize(
            lines, interchange_version = '4', chars = DEFAULT_CHARS, 
            application_reference = nil)
            super(lines, interchange_version, chars, application_reference)
            set_values
        end

        def set_values
            for group in @groups do
                erc = group.get_segments_by_tag("ERC").first
                unless erc.blank?
                    @application_error_id = erc.application_error_id
                    @code_list_qualifier = erc.code_list_qualifier
                    @responsible_agency = erc.responsible_agency
                end
            end
        end
    end
end
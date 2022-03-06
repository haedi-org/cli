module EDIFACT
    class PAISegment < Segment
        def initialize(raw, line_no, version = nil, chars = nil, subset = nil)
            super(raw, line_no, version, chars, subset)
            @payment_conditions = get_elements_by_code("4439").first
            @payment_guarentee = get_elements_by_code("4431").first
            @payment_means = get_elements_by_code("4461").first
            @code_list_qualifier = get_elements_by_code("1131").first
            @responsible_agency = get_elements_by_code("3055").first
            unless @responsible_agency.blank?
                apply_code_list()
            end
        end

        def apply_code_list
            # Payment conditions
            unless @payment_conditions.blank?
                data = $dictionary.code_list_lookup(
                    @responsible_agency.value,
                    get_code_list_qualifier(
                        @code_list_qualifier, @payment_conditions
                    ),
                    @payment_conditions.value
                )
                unless data.blank?
                    @payment_conditions.set_data_name(data["name"])
                    @payment_conditions.set_data_desc(data["desc"])
                end
            end
            # Payment conditions
            unless @payment_means.blank?
                data = $dictionary.code_list_lookup(
                    @responsible_agency.value,
                    get_code_list_qualifier(
                        @code_list_qualifier, @payment_means
                    ),
                    @payment_means.value
                )
                unless data.blank?
                    @payment_means.set_data_name(data["name"])
                    @payment_means.set_data_desc(data["desc"])
                end
            end
        end
    end
end

# PAI+1: :21: :10'
#     0 1 2  3 4

# 010  C534  PAYMENT INSTRUCTION DETAILS          M  1
#      4439  Payment conditions, coded            C     an..3
#      4431  Payment guarantee, coded             C     an..3
#      4461  Payment means, coded                 C     an..3
#      1131  Code list qualifier                  C     an..3
#      3055  Code list responsible agency, coded  C     an..3
#      4435  Payment channel, coded               C     an..3
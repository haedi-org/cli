module EDIFACT
    class NADSegment < Segment
        attr_reader :party_qualifier
        attr_reader :party_identification
        attr_reader :party_code_list
        attr_reader :party_responsible_agency

        def initialize(raw, line_no, version = nil, chars = nil, subset = nil)
            super(raw, line_no, version, chars, subset)
            @party_qualifier = get_elements_by_code("3035").first
            @party_identification = get_elements_by_code("3039").first
            @party_code_list = get_elements_by_code("1131").first
            @party_responsible_agency = get_elements_by_code("3055").first
            unless @party_responsible_agency.blank? or @party_code_list.blank?
                apply_code_list()
            end
            unless @party_responsible_agency.blank?
                validate_party_id()
            end
        end

        def match(qualifier)
            if @party_qualifier.data_value == qualifier
                return @party_identification
            else
                return nil
            end
        end

        def validate_party_id
            # EAN / GS1
            if @party_responsible_agency.value == "9"
                @party_identification.tap do |element|
                    if element.value.is_gtin_13?
                        result = true
                    else
                        result = InvalidGTINError.new
                    end
                    unless result == nil
                        element.set_integrity(result == true)
                        element.add_error(result) unless result == true
                    end
                end
            end
        end

        def apply_code_list
            params = [
                @party_responsible_agency.value,
                @party_code_list.value,
                @party_identification.value
            ]
            data = $dictionary.code_list_lookup(*params)
            unless data.blank?
                @party_identification.set_data_name(data["name"])
                @party_identification.set_data_desc(data["desc"])
            end
        end
    end
end

# 0   1  20 21  22
# NAD+CA+PL:172:ZZZ'

# 0   1  20             22
# NAD+DP+4260197450019::9'

# 010  3035  Party qualifier                      M  1  an..3
# 020  C082  PARTY IDENTIFICATION DETAILS         C  1
#      3039  Party id. identification             M     an..35
#      1131  Code list qualifier                  C     an..3
#      3055  Code list responsible agency, coded  C     an..3
# 030  C058  NAME AND ADDRESS                     C  1
#      3124  Name and address line                M     an..35
#      3124  Name and address line                C     an..35
#      3124  Name and address line                C     an..35
#      3124  Name and address line                C     an..35
#      3124  Name and address line                C     an..35
# 040  C080  PARTY NAME                           C  1
#      3036  Party name                           M     an..35
#      3036  Party name                           C     an..35
#      3036  Party name                           C     an..35
#      3036  Party name                           C     an..35
#      3036  Party name                           C     an..35
#      3045  Party name format, coded             C     an..3
# 050  C059  STREET                               C  1
#      3042  Street and number/p.o. box           M     an..35
#      3042  Street and number/p.o. box           C     an..35
#      3042  Street and number/p.o. box           C     an..35
#      3042  Street and number/p.o. box           C     an..35
# 060  3164  City name                            C  1 	an..35
# 070  3229  Country sub-entity identification    C  1 	an..9
# 080  3251  Postcode identification              C  1 	an..9
# 090  3207  Country, coded                       C  1 	an..3

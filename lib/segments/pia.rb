module EDIFACT
    class PIASegment < Segment
        attr_reader :date_time_qualifier, :date_time

        def initialize(raw, line_no, version = nil, chars = nil)
            super(raw, line_no, version, chars)
            @item_number_types = get_elements_by_code("7143")
            @item_numbers = get_elements_by_code("7140")
            unless @item_number_types.blank? or @item_numbers.blank?
                validate_identity_numbers(
                    @item_number_types,
                    @item_numbers
                )
            end
        end

        def validate_identity_numbers(qualifiers, number_elements)
            pairs = Array.new(qualifiers.length) do |i|
                [qualifiers[i].value, number_elements[i]]
            end
            for qualifier, element in pairs do
                element.value.tap do |value|
                    result = case qualifier
                    when 'IB' # ISBN International standard book number
                        value.is_isbn? ? true : InvalidISBNError.new
                    when 'IS' # ISSN International standard serial number
                        value.is_issn? ? true : InvalidISSNError.new
                    else
                        nil
                    end
                    unless result == nil
                        element.set_integrity(result == true)
                        element.add_error(result) unless result == true
                    end
                end
            end
        end
    end
end

# 010  4347  Product id. function qualifier       M  1   an..3 	
# 020  C212  ITEM NUMBER IDENTIFICATION           M  1   	
#      7140  Item number                          C     an..35 	
#      7143  Item number type, coded              C     an..3 	
#      1131  Code list qualifier                  C     an..3 	
#      3055  Code list responsible agency, coded  C     an..3 	
# 030  C212  ITEM NUMBER IDENTIFICATION           C  1   	
#      7140  Item number                          C     an..35 	
#      7143  Item number type, coded              C     an..3 	
#      1131  Code list qualifier                  C     an..3 	
#      3055  Code list responsible agency, coded  C     an..3 	
# 040  C212  ITEM NUMBER IDENTIFICATION           C  1   	
#      7140  Item number                          C     an..35 	
#      7143  Item number type, coded              C     an..3 	
#      1131  Code list qualifier                  C     an..3 	
#      3055  Code list responsible agency, coded  C     an..3 	
# 050  C212  ITEM NUMBER IDENTIFICATION           C  1   	
#      7140  Item number                          C     an..35 	
#      7143  Item number type, coded              C     an..3 	
#      1131  Code list qualifier                  C     an..3 	
#      3055  Code list responsible agency, coded  C     an..3 	
# 060  C212  ITEM NUMBER IDENTIFICATION           C  1   	
#      7140  Item number                          C     an..35 	
#      7143  Item number type, coded              C     an..3 	
#      1131  Code list qualifier                  C     an..3 	
#      3055  Code list responsible agency, coded  C     an..3 	
module EDIFACT
    class PIASegment < Segment
        attr_reader :product_id_function
        attr_reader :item_number_types, :item_numbers

        def initialize(raw, line_no, version = nil, chars = nil, subset = nil)
            super(raw, line_no, version, chars, subset)
            @product_id_function = get_elements_by_code("4347").first
            @item_number_types = get_elements_by_code("7143")
            @item_numbers = get_elements_by_code("7140")
            unless @item_number_types.blank? or @item_numbers.blank?
                validate_identity_numbers()
            end
        end

        def item_numbers_with_type
            pairs = Array.new(@item_number_types.length) do |i|
                [item_number_types[i], @item_numbers[i]]
            end
        end

        def validate_identity_numbers
            for qualifier, element in item_numbers_with_type do
                element.value.tap do |value|
                    result = case qualifier.value
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
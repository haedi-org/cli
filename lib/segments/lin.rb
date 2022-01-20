module EDIFACT
    class LINSegment < Segment
        attr_reader :line_item_number
        attr_reader :action_request
        attr_reader :item_number, :item_number_type
        attr_reader :sub_line_indicator

        def initialize(raw, line_no, version = nil, chars = nil, subset = nil)
            super(raw, line_no, version, chars, subset)
            @line_item_number = get_elements_by_code("1082").first
            @action_request = get_elements_by_code("1229").first
            @item_number = get_elements_by_code("7140").first
            @item_number_type = get_elements_by_code("7143").first
            @sub_line_indicator = get_elements_by_code("5495").first
            unless @item_number.blank? or @item_number_type.blank?
                @item_number = validate_item_number(
                    @item_number_type.value,
                    @item_number
                )
            end
        end

        def validate_item_number(qualifier, item_number)
            item_number.value.tap do |value|
                result = case qualifier
                when 'SRV' # EAN.UCC Global Trade Item Number
                    value.is_gtin_13? ? true : InvalidGTINError.new
                else
                    true
                end
                item_number.set_integrity(result == true)
                item_number.add_error(result) unless result == true
            end
            return item_number
        end
    end
end

#     12 30            31
# LIN+2++5412345123454:SRV'

#  010  1082  Line item number                     C  1  an..6
#  020  1229  Action request/notification, coded   C  1  an..3
#  030  C212  ITEM NUMBER IDENTIFICATION           C  1	
#       7140  Item number                          C     an..35
#       7143  Item number type, coded              C     an..3
#       1131  Code list qualifier                  C     an..3
#       3055  Code list responsible agency, coded  C     an..3
#  040  C829  SUB-LINE INFORMATION                 C  1
#       5495  Sub-line indicator, coded            C     an..3
#       1082  Line item number                     C     an..6
#  050  1222  Configuration level                  C  1  n..2
#  060  7083  Configuration, coded                 C  1  an..3
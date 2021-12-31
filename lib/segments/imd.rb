module EDIFACT
    class IMDSegment < Segment
        attr_reader :item_description_type
        attr_reader :item_characteristic
        attr_reader :item_description_id
        attr_reader :item_description

        def initialize(raw, line_no, version = nil, chars = nil)
            super(raw, line_no, version, chars)
            @item_description_type = get_elements_by_code("7077").first
            @item_characteristic = get_elements_by_code("7081").first
            @item_description_id = get_elements_by_code("7009").first
            @code_list_qualifier = get_elements_by_code("1131").first
            @responsible_agency = get_elements_by_code("3055").first
            @item_description = get_elements_by_code("7008")
        end

        def apply_association_code_list(qualifier)
            unless @item_characteristic.blank?
                data = $dictionary.code_list_lookup(
                    qualifier,
                    @item_characteristic.code,
                    @item_characteristic.value
                )
                unless data.blank?
                    @item_characteristic.set_data_name(data["name"])
                    @item_characteristic.set_data_desc(data["desc"])
                end
            end
        end

        def readable_description
            return (
                @item_description.map { |desc| desc.readable }.join(" ")
            )
        end
    end
end

# 0   1 2     3234          35
# IMD+F+ANM+::9:Energydrink:Summer-Edition'

# 010  7077  Item description type, coded         C  1  an..3
# 020  7081  Item characteristic, coded           C  1  an..3
# 030  C273  ITEM DESCRIPTION                     C  1
#      7009  Item description identification      C     an..17
#      1131  Code list qualifier                  C     an..3
#      3055  Code list responsible agency, coded  C     an..3
#      7008  Item description                     C     an..35
#      7008  Item description                     C     an..35
#      3453  Language, coded                      C     an..3
# 040  7383  Surface/layer indicator, coded       C  1  an..3
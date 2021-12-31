module EDIFACT
    class QTYSegment < Segment
        attr_reader :quantity_qualifier
        attr_reader :quantity
        attr_reader :measure_unit_qualifier

        def initialize(raw, line_no, version = nil, chars = nil)
            super(raw, line_no, version, chars)
            @quantity_qualifier = get_elements_by_code("6063").first
            @quantity = get_elements_by_code("6060").first
            @measure_unit_qualifier = get_elements_by_code("6411").first
        end

        def apply_association_code_list(qualifier)
            unless @measure_unit_qualifier.blank?
                @measure_unit_qualifier.apply_association_code_list(qualifier)
            end
        end
    end
end

# 0   10 11 12
# QTY+12:15:PCE'

# 010  C186  QUANTITY DETAILS        M  1
#      6063  Quantity qualifier      M     an..3
#      6060  Quantity                M     n..15
#      6411  Measure unit qualifier  C     an..3
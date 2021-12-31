module EDIFACT
    class PCISegment < Segment
        attr_reader :marking_instructions
        attr_reader :shipping_marks

        def initialize(raw, line_no, version = nil, chars = nil)
            super(raw, line_no, version, chars)
            @marking_instructions = get_elements_by_code("4233").first
            @shipping_marks = get_elements_by_code("7102")
        end

        def apply_association_code_list(qualifier)
            unless @marking_instructions.blank?
                data = $dictionary.code_list_lookup(
                    qualifier,
                    @marking_instructions.code,
                    @marking_instructions.value
                )
                unless data.blank?
                    @marking_instructions.set_data_name(data["name"])
                    @marking_instructions.set_data_desc(data["desc"])
                end
            end
        end
    end
end

# 010  4233  Marking instructions, coded          C  1  an..3
# 020  C210  MARKS & LABELS                       C  1
#      7102  Shipping marks                       M     an..35
#      7102  Shipping marks                       C     an..35
#      7102  Shipping marks                       C     an..35
#      7102  Shipping marks                       C     an..35
#      7102  Shipping marks                       C     an..35
#      7102  Shipping marks                       C     an..35
#      7102  Shipping marks                       C     an..35
#      7102  Shipping marks                       C     an..35
#      7102  Shipping marks                       C     an..35
#      7102  Shipping marks                       C     an..35
# 030  8275  Container/package status, coded      C  1  an..3
# 040  C827  TYPE OF MARKING                      C  1
#      7511  Type of marking, coded               M     an..3
#      1131  Code list qualifier                  C     an..3
#      3055  Code list responsible agency, coded  C     an..3
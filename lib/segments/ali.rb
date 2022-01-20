module EDIFACT
    class ALISegment < Segment
        attr_reader :country_of_origin
        attr_reader :type_of_duty_regime
        attr_reader :special_conditions

        def initialize(raw, line_no, version = nil, chars = nil, subset = nil)
            super(raw, line_no, version, chars)
            @country_of_origin = get_elements_by_code("3239").first
            @type_of_duty_regime = get_elements_by_code("9213").first
            @special_conditions = get_elements_by_code("4183")
        end

        def apply_association_code_list(qualifier)
            unless @country_of_origin.blank?
                @country_of_origin.apply_association_code_list(qualifier)
            end
        end
    end
end

# 010  3239  Country of origin, coded    C  1  an..3
# 020  9213  Type of duty regime, coded  C  1  an..3
# 030  4183  Special conditions, coded   C  1  an..3
# 040  4183  Special conditions, coded   C  1  an..3
# 050  4183  Special conditions, coded   C  1  an..3
# 060  4183  Special conditions, coded   C  1  an..3
# 070  4183  Special conditions, coded   C  1  an..3
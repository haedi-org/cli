module EDIFACT
    class MEASegment < Segment
        attr_reader :measurement_purpose
        attr_reader :property_measured
        attr_reader :measure_unit_qualifier
        attr_reader :measurement_value
        
        def initialize(raw, line_no, version = nil, chars = nil)
            super(raw, line_no, version, chars)
            @measurement_purpose = get_elements_by_code("6311").first
            @property_measured = get_elements_by_code("6313").first
            @measure_unit_qualifier = get_elements_by_code("6411").first
            @measurement_value = get_elements_by_code("6314").first
        end
    end
end

# 010  6311  Measurement purpose qualifier         M  1  an..3
# 020  C502  MEASUREMENT DETAILS                   C  1
#      6313  Property measured, coded              C     an..3
#      6321  Measurement significance, coded       C     an..3
#      6155  Measurement attribute identification  C     an..17
#      6154  Measurement attribute                 C     an..70
# 030  C174  VALUE/RANGE                           C  1
#      6411  Measure unit qualifier                M     an..3
#      6314  Measurement value                     C     an..18
#      6162  Range minimum                         C     n..18
#      6152  Range maximum                         C     n..18
#      6432  Significant digits                    C     n..2
# 040  7383  Surface/layer indicator, coded        C  1  an..3
module EDIFACT
    class GIDSegment < Segment
        attr_reader :goods_item_number
        
        def initialize(raw, line_no, version = nil, chars = nil, subset = nil)
            super(raw, line_no, version, chars, subset)
            @goods_item_number = get_elements_by_code("1496").first
        end
    end
end

# 010  1496  Goods item number                     C  1  n..5
# 020  C213  NUMBER AND TYPE OF PACKAGES           C  1
#      7224  Number of packages                    C     n..8
#      7065  Type of packages identification       C     an..17
#      1131  Code list qualifier                   C     an..3
#      3055  Code list responsible agency, coded   C     an..3
#      7064  Type of packages                      C     an..35
#      7233  Packaging related information, coded  C     an..3
# 030  C213  NUMBER AND TYPE OF PACKAGES           C  1
#      7224  Number of packages                    C     n..8
#      7065  Type of packages identification       C     an..17
#      1131  Code list qualifier                   C     an..3
#      3055  Code list responsible agency, coded   C     an..3
#      7064  Type of packages                      C     an..35
#      7233  Packaging related information, coded  C     an..3
# 040  C213  NUMBER AND TYPE OF PACKAGES           C  1
#      7224  Number of packages                    C     n..8
#      7065  Type of packages identification       C     an..17
#      1131  Code list qualifier                   C     an..3
#      3055  Code list responsible agency, coded   C     an..3
#      7064  Type of packages                      C     an..35
#      7233  Packaging related information, coded  C     an..3
# 050  C213  NUMBER AND TYPE OF PACKAGES           C  1
#      7224  Number of packages                    C     n..8
#      7065  Type of packages identification       C     an..17
#      1131  Code list qualifier                   C     an..3
#      3055  Code list responsible agency, coded   C     an..3
#      7064  Type of packages                      C     an..35
#      7233  Packaging related information, coded  C     an..3
# 060  C213  NUMBER AND TYPE OF PACKAGES           C  1
#      7224  Number of packages                    C     n..8
#      7065  Type of packages identification       C     an..17
#      1131  Code list qualifier                   C     an..3
#      3055  Code list responsible agency, coded   C     an..3
#      7064  Type of packages                      C     an..35
#      7233  Packaging related information, coded  C     an..3
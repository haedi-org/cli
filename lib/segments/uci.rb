module EDIFACT
    class UCISegment < Segment
        attr_reader :interchange_control_reference, :action, :syntax_error

        def initialize(raw, line_no, version = nil, chars = nil, subset = nil)
            super(raw, line_no, version, chars, subset)
            @interchange_control_reference = get_elements_by_code("0020").first
            @action = get_elements_by_code("0083").first
            @syntax_error = get_elements_by_code("0085").first
        end
    end
end

# 010  0020  Interchange control reference                      M  1  an..14
# 020  S002  INTERCHANGE SENDER                                 M  1
#      0004  Interchange sender identification                  M     an..35
#      0007  Identification code qualifier                      C     an..4
#      0008  Interchange sender internal identification         C     an..35
#      0042  Interchange sender internal sub-identification 	C     an..35
# 030  S003  INTERCHANGE RECIPIENT                              M  1
#      0010  Interchange recipient identification               M     an..35
#      0007  Identification code qualifier                      C     an..4
#      0014  Interchange recipient internal identification      C     an..35
#      0046  Interchange recipient internal sub-identification  C     an..35
# 040  0083  Action, coded                                      M  1  an..3
# 050  0085  Syntax error, coded                                C  1  an..3
# 060  0135  Service segment tag, coded                         C  1  an..3
# 070  S011  DATA ELEMENT IDENTIFICATION                        C  1
#      0098  Erroneous data element position in segment         M     n..3
#      0104  Erroneous component data element position          C     n..3
#      0136  Erroneous data element occurrence                  C     n..6
# 080  0534  Security reference number                          C  1  an..14
# 090  0138  Security segment position                          C  1  n..6
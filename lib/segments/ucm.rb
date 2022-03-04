module EDIFACT
    class UCMSegment < Segment
        attr_reader :action, :syntax_error

        def initialize(raw, line_no, version = nil, chars = nil, subset = nil)
            super(raw, line_no, version, chars, subset)
            @action = get_elements_by_code("0083").first
            @syntax_error = get_elements_by_code("0085").first
        end
    end
end

# UCM+ME002341+INVOIC:D:01B:UN:EAN010+4'

# 010  0062  Message reference number                    C  1   an..14
# 020  S009  MESSAGE IDENTIFIER                          C  1
#      0065  Message type                                M      an..6
#      0052  Message version number                      M      an..3
#      0054  Message release number                      M      an..3
#      0051  Controlling agency, coded                   M      an..3
#      0057  Association assigned code                   C      an..6
#      0110  Code list directory version number          C      an..6
#      0113  Message type sub-function identification    C      an..6
# 030  0083  Action, coded                               M  1   an..3
# 040  0085  Syntax error, coded                         C  1   an..3
# 050  0135  Service segment tag, coded                  C  1   an..3
# 060  S011  DATA ELEMENT IDENTIFICATION                 C  1
#      0098  Erroneous data element position in segment  M      n..3
#      0104  Erroneous component data element position   C      n..3
#      0136  Erroneous data element occurrence           C      n..6
# 070  0800  Package reference number                    C 	1   an..35
# 080  S020  REFERENCE IDENTIFICATION                    C 	99
#      0813  Reference qualifier                         M      an..3
#      0802  Reference identification number             M      an..35
# 090  0534  Security reference number                   C  1   an..14
# 100  0138  Security segment position                   C  1   n..6
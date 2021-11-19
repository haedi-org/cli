class UNBSegment < Segment
    def initialize(raw, line_no, version = nil, chars = nil)
        super(raw, line_no, version, chars)
    end
end

# UNB+UNOA:1+RECIPIENT:12:ADDR+PHONE:12:ROUT+090723:1010+1+PSWD:AA+APPL'

# 010  S001  SYNTAX IDENTIFIER                                  M  1
#      0001  Syntax identifier                                  M     a4
#      0002  Syntax version number                              M     an1
#      0080  Service code list directory version number         C     an..6
#      0133  Character encoding, coded                          C     an..3
# 020  S002  INTERCHANGE SENDER                                 M  1
#      0004  Interchange sender identification                  M     an..35
#      0007  Identification code qualifier                      C     an..4
#      0008  Interchange sender internal identification         C     an..35
#      0042  Interchange sender internal sub-identification     C     an..35
# 030  S003  INTERCHANGE RECIPIENT                              M  1
#      0010  Interchange recipient identification               M     an..35
#      0007  Identification code qualifier                      C     an..4
#      0014  Interchange recipient internal identification      C     an..35
#      0046  Interchange recipient internal sub-identification  C     an..35
# 040  S004  DATE AND TIME OF PREPARATION                       M  1
#      0017  Date                                               M     n8
#      0019  Time                                               M     n4
# 050  0020  Interchange control reference                      M  1  an..14
# 060  S005  RECIPIENT'S REFERENCE/PASSWORD DETAILS             C  1
#      0022  Recipient reference/password                       M     an..14
#      0025  Recipient reference/password qualifier             C     an2
# 070  0026  Application reference                              C  1  an..14
# 080  0029  Processing priority code                           C  1  a1
# 090  0031  Acknowledgement request                            C  1  n1
# 100  0032  Interchange agreement identifier                   C  1  an..35
# 110  0035  Test indicator                                     C  1  n1
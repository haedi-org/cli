UNB_DATE_TIME_QUALIFIER = 'Date/time of preparation'

class UNBSegment < Segment
    attr_reader :date, :time

    def initialize(raw, line_no, version = nil, chars = nil)
        super(raw, line_no, version, chars)
        @date = get_elements_by_code("0017").first
        @time = get_elements_by_code("0019").first
        interpret_date_time()
    end

    def interpret_date_time()
        # 101   YYMMDD
        # 102   CCYYMMDD
        unless @date.blank?
            date_format = nil
            date_format = '101' if @date.value.length == 6
            date_format = '102' if @date.value.length == 8
            unless date_format.blank?
                @date.set_data_name(
                    interpret_date(@date.value, date_format)
                )
            end
        end
        # 401   HHMM
        unless @time.blank?
            time_format = nil
            time_format = '401' if @time.value.length == 4
            unless time_format.blank?
                @time.set_data_name(
                    interpret_date(@time.value, time_format)
                )
            end
        end
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
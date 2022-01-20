module EDIFACT
    class UNHSegment < Segment
        attr_reader :message_reference
        attr_reader :message_type, :controlling_agency
        attr_reader :association_assigned_code

        def initialize(raw, line_no, version = nil, chars = nil, subset = nil)
            super(raw, line_no, version, chars)
            @message_reference = get_elements_by_code("0062").first
            @message_type = get_elements_by_code("0065").first
            @message_version = get_elements_by_code("0052").first
            @message_release = get_elements_by_code("0054").first
            @controlling_agency = get_elements_by_code("0051").first
            @association_assigned_code = get_elements_by_code("0057").first
            debug
        end

        def debug
            for element in flatten do
                puts [element.code, element.value].join("\t")
            end
            puts @raw
        end

        def assn_assigned_code
            return @association_assigned_code
        end

        def version_key
            return @message_version.value + @message_release.value
        end
    end
end

# UNH+321+DESADV:D:96A:UN:EAN005'
#                      ^ Controlling agency
#                         ^ Association assigned code

# 010  0062  Message reference number                         M  1  an..14 	
# 020  S009  MESSAGE IDENTIFIER                               M  1  	
#      0065  Message type                                     M     an..6 	
#      0052  Message version number                           M     an..3 	
#      0054  Message release number                           M     an..3 	
#      0051  Controlling agency, coded                        M     an..3 	
#      0057  Association assigned code                        C     an..6 	
#      0110  Code list directory version number               C     an..6 	
#      0113  Message type sub-function identification         C     an..6 	
# 030  0068  Common access reference                          C  1  an..35 	
# 040  S010  STATUS OF THE TRANSFER                           C  1  	
#      0070  Sequence of transfers                            M     n..2 	
#      0073  First and last transfer                          C     a1 	
# 050  S016  MESSAGE SUBSET IDENTIFICATION                    C  1  	
#      0115  Message subset identification                    M     an..14 	
#      0116  Message subset version number                    C     an..3 	
#      0118  Message subset release number                    C     an..3 	
#      0051  Controlling agency, coded                        C     an..3 	
# 060  S017  MESSAGE IMPLEMENTATION GUIDELINE IDENTIFICATION  C  1  	
#      0121  Message implementation guideline identification  M     an..14 	
#      0122  Message implementation guideline version number  C     an..3 	
#      0124  Message implementation guideline release number  C     an..3 	
#      0051  Controlling agency, coded                        C     an..3 	
# 070  S018  SCENARIO IDENTIFICATION                          C  1  	
#      0127  Scenario identification                          M     an..14 	
#      0128  Scenario version number                          C     an..3 	
#      0130  Scenario release number                          C     an..3 	
#      0051  Controlling agency, coded                        C     an..3 	
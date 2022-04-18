module EDIFACT
    class PACSegment < Segment
        attr_reader :number_of_packages
        attr_reader :packaging_level
        attr_reader :type_of_packages_id

        def initialize(raw, line_no, version = nil, chars = nil, subset = nil)
            super(raw, line_no, version, chars, subset)
            @number_of_packages = get_elements_by_code("7224").first
            @packaging_level = get_elements_by_code("7075").first
            @type_of_packages_id = get_elements_by_code("7065").first
        end

        def match(qualifier)
            if @type_of_packages_id.data_value == qualifier
                return @number_of_packages
            else
                return nil
            end
        end

        def apply_association_code_list(qualifier)
            unless @type_of_packages_id.blank?
                @type_of_packages_id.apply_association_code_list(qualifier)
            end
        end
    end
end

# 010  7224  Number of packages                                 C  1  n..8
# 020  C531  PACKAGING DETAILS                                  C  1
#      7075  Packaging level, coded                             C     an..3
#      7233  Packaging related information, coded               C     an..3
#      7073  Packaging terms and conditions, coded              C     an..3
# 030  C202  PACKAGE TYPE                                       C  1
#      7065  Type of packages identification                    C  	  an..17
#      1131  Code list qualifier                                C  	  an..3
#      3055  Code list responsible agency, coded                C  	  an..3
#      7064  Type of packages                                   C  	  an..35
# 040  C402  PACKAGE TYPE IDENTIFICATION                        C  1
#      7077  Item description type, coded                       M  	  an..3
#      7064  Type of packages                                   M  	  an..35
#      7143  Item number type, coded                            C  	  an..3
#      7064  Type of packages                                   C  	  an..35
#      7143  Item number type, coded                            C  	  an..3
# 050  C532  RETURNABLE PACKAGE DETAILS                         C  1
#      8395  Returnable package freight payment responsibility  C  	  an..3
#      8393  Returnable package load contents, coded            C  	  an..3
module EDIFACT
    class EQDSegment < Segment
        attr_reader :equipment_qualifier
        attr_reader :equipment_id_number
        attr_reader :full_empty_indicator
        attr_reader :equipment_size_and_type

        def initialize(raw, line_no, version = nil, chars = nil, subset = nil)
            super(raw, line_no, version, chars, subset)
            @equipment_qualifier = get_elements_by_code("8053").first
            @equipment_id_number = get_elements_by_code("8260").first
            @full_empty_indicator = get_elements_by_code("8169").first
            @equipment_size_and_type = get_elements_by_code("8155").first
        end

        def apply_association_code_list(qualifier)
            # SMDG
            if qualifier == "306"
                if @equipment_size_and_type.value.is_iso_6346_size_and_type?
                    data = parse_iso_6346_size_type(
                        @equipment_size_and_type.value
                    )
                    unless data.blank?
                        @equipment_size_and_type.set_data_name(data["name"])
                        @equipment_size_and_type.set_data_desc(data["desc"])
                        @equipment_size_and_type.set_integrity(true)
                    end
                end
            end
        end

        def apply_association_validation(qualifier)
            # SMDG
            if qualifier == "306"
                if !(@equipment_qualifier.blank? or @equipment_id_number.blank?)
                    if @equipment_qualifier.value == "CN"
                        @equipment_id_number.tap do |element|
                            if element.value.is_iso_6346_container_code?
                                result = true
                            else
                                result = InvalidISO6346ContainerCode.new
                            end
                            unless result == nil
                                element.set_integrity(result == true)
                                element.add_error(result) unless result == true
                            end
                        end
                    end
                end
            end
        end

        def apply_code_list
            
           #data = $dictionary.code_list_lookup(
           #    "6346", "SIZETYPE", @equipment_size_and_type.value
           #)
           #unless data.blank?
           #    @equipment_size_and_type.set_data_name(data["name"])
           #    @equipment_size_and_type.set_data_desc(data["desc"])
           #end
        end

        def debug
            out = []
            unless (@equipment_id_number.value.is_iso_6346_container_code?)
                out << ""
                out << @equipment_qualifier.readable
                out << @full_empty_indicator.readable
                out << @equipment_size_and_type.readable
                out << @equipment_id_number.value
            end
            return out
        end
    end
end

# 0   1  2           3    4 5 6
# EQD+CN+TCKU3379279+22G0+ + +4'

# 010  8053  Equipment qualifier                     M  1  an..3 	
# 020  C237  EQUIPMENT IDENTIFICATION                C  1
#      8260  Equipment identification number         C     an..17 	
#      1131  Code list qualifier                     C     an..3 	
#      3055  Code list responsible agency, coded     C     an..3 	
#      3207  Country, coded                          C     an..3 	
# 030  C224  EQUIPMENT SIZE AND TYPE                 C  1 		
#      8155  Equipment size and type identification  C     an..10 	
#      1131  Code list qualifier                     C     an..3 	
#      3055  Code list responsible agency, coded     C     an..3 	
#      8154  Equipment size and type                 C     an..35 	
# 040  8077  Equipment supplier, coded 	             C  1  an..3 	
# 050  8249  Equipment status, coded                 C  1  an..3 	
# 060  8169  Full/empty indicator, coded 	         C  1  an..3 	
module EDIFACT # UNICORN
    class MCRSegment < Segment
        attr_reader :date_time_qualifier, :date_time

        def initialize(raw, line_no, version = nil, chars = nil, subset = nil)
            super(raw, line_no, version, chars, subset)
            @date = get_elements_by_code("0017").first
            @time = get_elements_by_code("0019").first
            unless @date.blank?
                @date.set_data_name(
                    EDIFACT::interpret_date(@date.value, "101")
                )
            end
            unless @time.blank?
                @time.set_data_name(
                    EDIFACT::interpret_date(@time.value, "401")
                )
            end
        end
    end
end

# 010  C507  DATE/TIME/PERIOD                   M  1 		
#      2005  Date/time/period qualifier         M     an..3 	
#      2380  Date/time/period                   C     an..35 	
#      2379  Date/time/period format qualifier  C     an..3 	
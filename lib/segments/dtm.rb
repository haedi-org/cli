class DTMSegment < Segment
    attr_reader :date_time_qualifier, :date_time

    def initialize(raw, line_no, version = nil, chars = nil)
        super(raw, line_no, version, chars)
        @date_time_qualifier = get_elements_by_code("2005").first
        @date_time = get_elements_by_code("2380").first
        @date_time_format = get_elements_by_code("2379").first
        unless @date_time.blank? or @date_time_format.blank?
            @date_time.set_data_name(
                interpret_date(@date_time.value, @date_time_format.value)
            )
        end
    end
end

# 010  C507  DATE/TIME/PERIOD                   M  1 		
#      2005  Date/time/period qualifier         M  an..3 	
#      2380  Date/time/period                   C  an..35 	
#      2379  Date/time/period format qualifier  C  an..3 	
module EDIFACT # UNICORN
    class RDQSegment < Segment
        attr_reader :date, :time

        def initialize(raw, line_no, version = nil, chars = nil, subset = nil)
            super(raw, line_no, version, chars, subset)
            @date = get_elements_by_code("U247").first
            @time = get_elements_by_code("U248").first
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
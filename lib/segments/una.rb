#class UNASegment < Segment
#    def initialize(raw, line_no)
#        @raw = raw
#        @data = @raw.dup
#        @line_no = line_no
#        @error = nil
#        @tag = Tag.new(raw[0, 3], version)
#        @elements = []
#        set_character_elements()
#    end
#
#    def set_character_elements
#        arr = ["UNA1", "UNA2", "UNA3", "UNA4"]
#        for index in arr do
#            @elements << 
#        end
#        @component_element_seperator = @raw[3]
#        @data_element_seperator = @raw[4]
#        @decimal_mark = @raw[5]
#        @release_character = @raw[6]
#        @repetition_seperator = @raw[7]
#        @segment_terminator = @raw[8]
#    end
#end
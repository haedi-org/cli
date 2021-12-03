module EDIFACT
    class UNASegment < Segment
        def initialize(raw, line_no, version = nil, chars = nil)
            @raw = raw
            @data = @raw.dup
            @line_no = line_no
            @version = version
            @error = nil
            @tag = Tag.new(raw[0, 3], version)
            @elements = []
            @spec = $dictionary.una_segment_specification()
            set_character_elements()
        end

        def punctuation
            return @chars
        end

        def set_character_elements
            index = 0
            @elements = @spec["structure"].map do |code|
                index += 1
                params = [code, @version, [index], @raw[2 + index]]
                Element.new(*params)
            end
            # Set values for elements
            @elements.each do |element|
                name = @spec.dig("elements", element.code, "name")
                element.set_name(name) unless name.blank?
                repr = @spec.dig("elements", element.code, "repr")
                element.set_repr(repr) unless repr.blank?
            end
            # Set variables
            @chars = Punctuation.new(
                @elements[0].value, @elements[1].value, @elements[2].value,
                @elements[3].value, @elements[4].value, @elements[5].value,
            )
        end
    end
end
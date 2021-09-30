class Segment
    def initialize(raw, line_no, version = nil, chars = nil)
        @raw = raw
        @data = @raw.dup
        @version = version
        @chars = chars
        @elements = []
        @tag = Tag.new(raw[0, 3])
        # Retrieve specification from dictionary
        @spec = $dictionary.segment_specification(@tag.value, @version)
        split_data_by_chars() unless @chars.blank?
        apply_segment_spec() unless @spec.blank?
    end

    def apply_segment_spec
        index = 0 # Skip tag
        @elements = @spec["structure"].map do |code|
            is_composite = (code.first == "C")
            params = [code, @version, get_data((index += 1), is_composite)]
            is_composite ? Composite.new(*params) : Element.new(*params)
        end
    end

    def split_data_by_chars
        # Remove last character if segment terminator
        @data = @data[0..-2] if (@data[-1] == @chars.segment_terminator)
        # Split component data elements within line
        @data = @data.split_with_release(
            @chars.data_element_seperator, @chars.release_character
        )
        # Split data elements within components
        @data.map! do |component|
            component.split_with_release(
                @chars.component_element_seperator, @chars.release_character
            ) 
        end
    end

    def get_data(index, is_composite = false)
        return nil if index >= @data.length
        return is_composite ? @data[index] : @data[index].first
    end

    def debug
        out = ["", "SEGMENT : #{@data.inspect}"]
        @elements.each { |element| out << element.debug }
        return out
    end
end
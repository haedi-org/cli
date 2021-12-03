module EDIFACT
    class Segment
        attr_reader :elements, :line_no, :raw, :error
        attr_reader :tag, :data, :chars, :version, :spec

        def initialize(raw, line_no, version = nil, chars = nil)
            @raw = raw
            @data = @raw.dup
            @line_no = line_no
            @version = version
            @chars = chars
            @elements = []
            @error = nil
            @tag = Tag.new(raw[0, 3], version)
            # Retrieve specification from dictionary
            unless $dictionary.is_service_segment?(@tag.value)
                @spec = $dictionary.segment_specification(@tag.value, @version)
            else
                @spec = $dictionary.service_segment_specification(@tag.value)
            end
            split_data_by_chars() unless @chars.blank?
            apply_segment_spec() unless @spec.blank?
        end

        def get_elements_by_code(code)
            return (flatten.map { |e| e.code == code ? e : nil }).compact
        end

        def truncated_elements
            data = @elements.map { |element| element.blank? ? nil : element }
            data = data[0..-2] until (data.last != nil) or (data.empty?)
            return data.empty? ? [] : @elements.first(data.length)
        end

        def flatten
            arr = []
            for element in @elements do
                arr << (element.is_a?(Composite) ? element.elements : element)
            end
            return arr.flatten
        end

        def apply_segment_spec
            index = 0 # Skip tag
            @elements = @spec["structure"].map do |code|
                is_composite = ((code.first == "C") or (code.first == "S"))
                index += 1
                params = [code, @version, [index], get_data(index, is_composite)]
                is_composite ? Composite.new(*params) : Element.new(*params)
            end
        end

        def split_data_by_chars
            # Remove last character if segment terminator
            @data = @data[0..-2] if (@data[-1] == @chars.segment_terminator)
            # Split component data elements within line
            @data = @data.split_with_release(
                @chars.data_element_separator,
                @chars.release_character
            )
            # Split data elements within components
            @data.map! do |component|
                component.split_with_release(
                    @chars.component_element_separator,
                    @chars.release_character
                )
            end
        end

        def get_data(index, is_composite = false)
            return nil if index >= @data.length
            return is_composite ? @data[index] : @data[index].first
        end

        def is_valid?
            return true
        end

        def is?(tag_value)
            return @tag.value == tag_value
        end

        def debug
            out = ["", "SEGMENT : #{@data.inspect}"]
            @elements.each { |element| out << element.debug }
            return out
        end
    end
end
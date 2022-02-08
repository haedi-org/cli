module EDIFACT
    class Segment
        attr_reader :elements, :line_no, :raw
        attr_reader :tag, :data, :chars, :version, :spec

        def initialize(raw, line_no, version = nil, chars = nil, subset = nil)
            @raw = raw
            @data = @raw.dup
            @line_no = line_no
            @version = version
            @chars = chars
            @subset = subset
            @elements = []
            @errors = []
            @tag = Tag.new(raw[0, 3], version, subset)
            # Retrieve specification from dictionary
            set_spec()
            # Assign tag values if not already set
            set_tag_values() if @tag.name.blank? && @spec.not_blank?
            split_data_by_chars() unless @chars.blank?
            unless @spec.blank?
                apply_segment_spec()
            else
                parse_without_spec()
                @errors << [NoSpecificationError.new, [@line_no]]
            end
        end

        def errors
            element_errors = []
            for element in flatten do
                unless element.is_valid?
                    for error, position in element.errors do
                        position = [@line_no, position].flatten
                        element_errors << [error, position]
                    end
                end
            end
            return (@errors + element_errors).compact
        end

        def apply_association_code_list(qualifier)
            for element in self.flatten do
                element.apply_association_code_list(qualifier)
            end
        end

        def set_spec()
            unless $dictionary.is_service_segment?(@tag.value, @subset)
                params = [@tag.value, @version, @subset]
                @spec = $dictionary.segment_specification(*params)
            else
                params = [@tag.value, nil, @subset]
                @spec = $dictionary.service_segment_specification(*params)
            end
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
               #is_composite = ((code.first == "C") or (code.first == "S"))
                is_composite = @spec["elements"][code]["composite"]
                index += 1
                params = [
                    code, @version, [index], 
                    get_data(index, is_composite), @subset
                ]
                is_composite ? Composite.new(*params) : Element.new(*params)
            end
        end

        def parse_without_spec
            # TODO
        end

        def set_tag_values
            @tag.name = @spec["name"] if @spec.key?("name")
            @tag.desc = @spec["desc"] if @spec.key?("desc")
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
            return errors().empty?
        end

        def is?(tag_value)
            return @tag.value == tag_value
        end
        
        def get_code_list_qualifier(code_list, element)
            return code_list.value unless code_list.blank?
            return element.code unless element.blank?
            return nil
        end

        def debug
            out = ["", "SEGMENT : #{@data.inspect}"]
            @elements.each { |element| out << element.debug }
            return out
        end
    end
end
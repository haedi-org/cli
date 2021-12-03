module EDIFACT
    class Composite < Element
        attr_reader :elements, :data_values

        def initialize(code, version, position, values = [])
            @code = code
            @version = version
            @position = position
            @data_values = values.blank? ? [] : values
            @elements = []
            unless $dictionary.is_service_composite?(@code)
                @spec = $dictionary.composite_specification(@code, @version)
            else
                @spec = $dictionary.service_composite_specification(@code)
            end
            apply_composite_spec() unless @spec.blank?
        end

        def blank?
            return @data_values.empty?
        end

        def get_value(index)
            return nil if index >= @data_values.length
            return @data_values[index]
        end

        def truncated_elements
            data = @elements.map { |element| element.blank? ? nil : element }
            data = data[0..-2] until (data.last != nil) or (data.empty?)
            return data.empty? ? [] : @elements.first(data.length)
        end

        def apply_composite_spec
            index = -1
            @elements = @spec["elements"].map do |code, data|
                index += 1
                params = [code, @version, [@position, index], get_value(index)]
                Element.new(*params)
            end
        end

        def debug
            out = []
            @elements.each { |element| out << element.debug }
            return out
        end
    end
end
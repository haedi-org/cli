class Composite < Element
    attr_reader :elements

    def initialize(code, version, position, values = [])
        @code = code
        @version = version
        @position = position
        @values = values.blank? ? [] : values
        @elements = []
        @spec = $dictionary.composite_specification(@code, @version)
        apply_composite_spec() unless @spec.blank?
    end

    def get_value(index)
        return nil if index >= @values.length
        return @values[index]
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
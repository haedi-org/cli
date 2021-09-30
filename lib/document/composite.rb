class Composite < Element
    def initialize(code, version, values = [])
        @code = code
        @version = version
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
            params = [code, @version, get_value(index += 1)]
            Element.new(*params)
        end
    end

    def debug
        out = []
        @elements.each { |element| out << element.debug }
        return out
    end
end
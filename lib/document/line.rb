class Line
    attr_reader :raw, :tag, :data, :line_no, :chars, :version, :elements

    def initialize(data, line_no, version, chars)
        @raw = data
        @line_no = line_no
        @version = version
        @chars = chars
        @data = @raw.dup
        @tag = tag
        @elements = []
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

    def define(position, element_code, is_coded = false, version = nil)
        return nil if data_at(@line_no, *position).blank?
        return Element.new(
            self, position, element_code, 
            :is_coded => is_coded, :version => version
        )
    end

    def data_at(line, a, b = nil, code = nil, version = nil)
        return nil unless (length_at() > a) && (b.blank? || length_at(a) > b)
        return @data[a] if b.blank?
        version = @version.ref if version.blank? && (!code.blank?)
        return code.blank? ? @data[a][b] : ref(code, data_at(a, b, version))
    end

    def length_at(index = nil)
        return index.blank? ? @data.length : @data[index].length
    end

    def qualifier_at(code, value, version = @version.ref, list = "UNCL")
        return nil if value.blank?
        code_list = list + "_" + version
        return lookup_qualifier(code_list, code, value)
    end

    def tag
        loc = [@line_no, 0, 0]
        desc = ["", ""]
        # Service tags
        desc = lookup_tag("40100_0135", data_at(*loc))
        return Tag.new(loc, data_at(*loc), *desc) unless desc.first.blank?
        # Other tags
        desc = lookup_tag("EDSD", data_at(*loc))
        return Tag.new(loc, data_at(*loc), *desc) unless desc.first.blank?
        # Return with no reference
        return Tag.new(loc, data_at(*loc), *desc)
    end

    def push_elements(elements)
        elements.compact.each { |e| @elements << e }
    end

    def debug
        puts "[ #{tag.ref} ] #{@raw}\n\n"
    end

    def rows
        data = []
        for element in @elements do
            next unless element.is_a?(Element) && !element.data_value.blank?
            data_description = element.data_description
            data_value = element.data_value
            use_ref = (element.is_coded? && !element.data_interpreted.blank?)
            use_ref ||= DATE_CODES.include?(element.code)
            data_interpreted = use_ref ? element.data_interpreted : data_value
            data << [
                element.position, [
                    element.code, element.definition,
                    data_value, data_interpreted, data_description
                ]
            ]
        end
        return data
    end
end
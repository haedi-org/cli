class Line
    attr_reader :raw, :tag, :data, :line_no, :chars, :version, :elements

    def initialize(data, line_no, version, chars)
        @raw = data
        @line_no = line_no
        @version = version
        @chars = chars
        @data = @raw.dup
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
        # Assign tag and rules after data is processed
        @tag = assign_tag()
        @rules = assign_rules()
    end

    def define(position, element_code, is_coded = false, version = nil)
        return nil if value_at(*position).blank?
        element = Element.new(
            self, position, element_code, 
            :is_coded => is_coded, :version => version
        )
        return element if @rules.blank?
        element.set_rule(get_rule(*position))
        return element
    end

    def get_rule(a, b = 0)
        a = a - 1
        return {} unless (@rules.length > a)
        return {} unless (@rules[a]["segments"].length > b)
        return @rules[a]["segments"][b]
    end

    def value_at(a, b = nil)
        return nil unless (length_at() > a) && (b.blank? || length_at(a) > b)
        return @data[a][0] if b.blank?
        return @data[a][b]
    end

    def qualifier_at(code, value, version = nil, list = "UNCL")
        version = @version.ref if version.blank? && @version.is_a?(Version)
        return nil if value.blank? or version.blank?
        code_list = list + "_" + version
        return lookup_qualifier(code_list, code, value)
    end

    def data_at(a, b = nil, code = nil, version = nil)
        value = value_at(a, b)
        return value if value.blank?
        version = @version.ref if version.blank? && (!code == nil)
        return code.blank? ? value : qualifier_at(code, value)
    end

    def length_at(index = nil)
        return index.blank? ? @data.length : @data[index].length
    end

    def assign_tag()
        data = value_at(0)
        loc = [@line_no, 0, nil]
        desc = ["", ""]
        # Service tags
        desc = lookup_tag("40100_0135", data)
        return Tag.new(loc, data, *desc) unless desc.first.blank?
        # Other tags
        desc = lookup_tag("EDSD", data)
        return Tag.new(loc, data, *desc) unless desc.first.blank?
        # Return with no reference
        return Tag.new(loc, data, *desc)
    end

    def assign_rules()
        return {} if @version == nil
        rule_name = @tag.value + "_" + @version.ref
        rule_path = SEGMENT_RULES_PATH + rule_name + JSON_EXT
        rule_data = read_json(rule_path)
        return rule_data.blank? ? {} : rule_data
    end

    def push_elements(elements)
        elements.compact.flatten.each { |e| @elements << e }
    end

    def debug_rules()
        unless @rules.blank?
            for element in @elements do
                puts element.code
                unless element.rule.blank?
                    puts element.rule.max_length?
                    puts element.rule.mandatory?
                end
            end
        end
    end

    def debug()
        puts "[ #{tag.value} ] #{@raw}\n\n"
    end

    def rows()
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
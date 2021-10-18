class Line
    attr_reader :raw, :tag, :data, :line_no, :chars, :version, :elements, :valid

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
            @chars.data_element_separator, @chars.release_character
        )
        # Split data elements within components
        @data.map! do |component|
            component.split_with_release(
                @chars.component_element_separator, @chars.release_character
            ) 
        end
        # Assign tag and rules after data is processed
        @tag = assign_tag()
        @rules = assign_rules()
        @valid = true
    end

    def is_valid?
        return @valid == true
    end

    def set_validity(bool)
        @valid = bool
    end

    def message
        return nil if self.is_valid?
        return @valid.message
    end

    def define(position, element_code, is_coded = false, version = nil)
        return nil if value_at(*position).blank?
        element = Element.new(
            self, position, element_code, 
            :is_coded => is_coded, :version => version
        )
        return element if @rules.blank?
        element.set_rule(*get_rule(*position))
        return element
    end

    def get_rule(a, b = 0)
        a = a - 1
        return {} unless (@rules.length > a)
        return {} unless (@rules[a]["segments"].length > b)
        return [@rules[a]["segments"][b], @rules[a]]
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

    def element_at(a, b = 0)
        for element in @elements do
            return element if element.position == [@line_no, a, b]
        end
        return nil
    end

    def length_at(index = nil)
        return index.blank? ? @data.length : @data[index].length
    end

    def assign_tag()
        data = value_at(0)
        loc = [@line_no, 0, nil]
        desc = ["", ""]
        # Service tags
        desc = lookup_tag(data)
        return Tag.new(loc, data, *desc)
    end

    def assign_rules()
        return {} if @version == nil
        rule_name = @tag.value + "_" + @version.ref
        rule_path = SEGMENT_RULES_PATH + "/" + rule_name + JSON_EXT
        unless File.file?(rule_path)
            rule_path = SEGMENT_RULES_PATH + "/"  + @tag.value + JSON_EXT
        end
        rule_data = read_json(rule_path)
        return rule_data.blank? ? {} : rule_data
    end

    def push_elements(elements)
        elements.compact.flatten.each { |e| @elements << e }
        self_validate()
    end

    def self_validate()
        unless @rules.blank?
            self.set_validity(true)
            @rules.each_with_index do |rules, a|
                rules["segments"].each_with_index do |rule, b|
                    element = element_at(a + 1, b)
                    unless element.blank?
                        # Element exists
                        element.self_validate()
                    else
                        # Element doesn't exist
                        if SegmentRule.new(rule).mandatory?
                            self.set_validity(MandatoryFieldError.new)
                        end
                    end
                end
            end
        end
    end

    def debug_rules()
        out = []
        unless @rules.blank?
            out << ""
            out << self.raw
            @rules.each_with_index do |rules, a|
                rules["segments"].each_with_index do |rule, b|
                    element = element_at(a + 1, b)
                    out << rule.inspect
                    unless element.blank?
                        out << element.value
                    else
                        if SegmentRule.new(rule).mandatory?
                            self.set_validity(MandatoryFieldError.new)
                        end
                    end
                end
            end
        end
        return out
    end

    def debug()
        out = []
        out << "[ #{tag.value} ] #{@raw}\n\n"
        return out
    end

    def rows()
        data = []
        for element in @elements do
            next unless element.is_a?(Element) && !element.data_value.blank?
            data_description = element.data_description
            data_value = element.data_value
            data_valid = element.is_valid?
            use_ref = (element.is_coded? && !element.data_interpreted.blank?)
            use_ref ||= DATE_CODES.include?(element.code)
            data_interpreted = use_ref ? element.data_interpreted : data_value
            data << [
                element.position, [
                    element.code, element.definition,
                    data_value, data_interpreted, data_description, data_valid
                ]
            ]
        end
        return data
    end
end
# position           => [1, 1, 2] (line, a, b)
# element_code       => 3035
# element_definition => Party function code qualifier
# data_value         => BY
# data_interpreted   => Buyer
# data_description   => Party to whom merchandise and/or service is sold.

class Element
    attr_reader :position
    attr_reader :element_code, :element_definition
    attr_reader :data_value, :data_interpreted, :data_description
    attr_reader :rule

    def initialize(segment, position, element_code, is_coded: false, version: nil, data_value: nil)
        @version = version == nil && segment.version != nil ? segment.version.ref : version
        @position = [segment.line_no] + position
        @element_code = element_code
        @is_coded = is_coded
        @data_value = data_value == nil ? get_data_value(segment) : data_value
        @element_definition = define_element_code(element_code).definition
        @data_description, @data_interpreted = get_referenced_data(segment)
        @rule = nil
    end

    def get_data_value(segment)
        data_value = segment.value_at(*@position.without_first)
        data_value = data_value.join("\n") if data_value.is_a?(Array)
        return data_value
    end

    def get_referenced_data(segment)
        args = [@element_code, @data_value, @version]
        qualifier = segment.qualifier_at(*args) if self.is_coded?
        return ["", ""] unless defined?(qualifier) && qualifier != nil 
        return [qualifier.definition, qualifier.reference]
    end
    
    def set_interpreted_data(value)
        @data_interpreted = value
    end

    def set_rule(rule)
        @rule = rule if rule.is_a?(SegmentRule)
        @rule = SegmentRule.new(rule) unless rule.blank?
    end

    def is_coded?
        return @is_coded
    end

    def code
        return @element_code
    end

    def definition
        return @element_definition
    end

    def value
        return @data_value
    end
end
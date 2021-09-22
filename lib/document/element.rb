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
        @valid = true
    end

    def is_valid?
        return @valid
    end

    def set_validity(bool)
        @valid = bool
    end

    def get_data_value(segment)
        data_value = segment.value_at(*@position.tail)
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

    def set_rule(rule, parent = {})
        @rule = rule if rule.is_a?(SegmentRule)
        inherited_m_c = parent.key?("m/c") ? parent["m/c"] : "C"
        @rule = SegmentRule.new(rule, inherited_m_c) unless rule.blank?
    end

    def self_validate()
        unless @rule.blank?
            # Check data value is alphanumeric
            if @rule.alphanumeric? and (!@data_value.is_alphanumeric?)
                set_validity(FieldRepresentationError.new)
            end
            # Check data value is numeric
            if @rule.numeric? and (!@data_value.is_numeric?)
                set_validity(FieldRepresentationError.new)
            end
            # Check length of data value for variable length
            if @rule.variable_length? && (@rule.length < @data_value.length)
                set_validity(FieldLengthError.new)
            end
            # Check length of data value for fixed length
            if @rule.fixed_length? && (@rule.length != @data_value.length)
                set_validity(FieldLengthError.new)
            end
        end
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

    def interpreted
        return value if @data_interpreted.blank?
        return @data_interpreted
    end

    def empty?
        return ((@data_value == nil) or (@data_value == ""))
    end
end
module EDIFACT
    class Element
        attr_reader :code, :position
        attr_reader :name, :desc, :repr
        attr_reader :data_value, :data_name, :data_desc
        attr_reader :errors

        def initialize(code, version, position, value = "")
            @code = code
            @version = version
            @data_value = value == nil ? "" : value
            @position = position
            @integrity = false
            @errors = []
            # Retrieve and apply coded data
            @coded_data = $dictionary.coded_data_reference(code, value, version)
            apply_coded_data()
            # Retrieve and apply element specification data
            unless $dictionary.is_service_element?(@code)
                @spec = $dictionary.element_specification(@code, @version)
            else
                @spec = $dictionary.service_element_specification(@code)
            end
            apply_element_spec()
            check_against_repr() unless @repr.blank?
        end

        def check_against_repr
            rule = Rule.new(@spec)
            if @data_value.blank?
                add_error(MandatoryFieldError.new) unless rule.conditional?
                return
            end
            unless rule.check_length(@data_value)
                add_error(InvalidLengthError.new(rule.describe_length))
            end
            unless rule.check_symbols(@data_value)
                add_error(InvalidSymbolsError.new(rule.describe_symbols))
            end
        end

        def is_valid?
            return (
                (@errors.blank?) or (@errors.uniq == [NoElementError.new])
            )
        end

        def has_integrity?
            return @integrity
        end

        def error
            return NoElementError.new if @errors.blank?
            return @errors.first
        end

        def add_error(err)
            @errors = (@errors + [err]).uniq
        end

        def set_integrity(integrity)
            @integrity = integrity
        end

        def blank?
            return @data_value.blank?
        end

        def apply_coded_data
            @data_name = @coded_data.dig("name")
            @data_desc = @coded_data.dig("desc")
        end

        def apply_element_spec
            @name = @spec.dig("name")
            @desc = @spec.dig("desc")
            @repr = @spec.dig("repr")
            @name = "" if @name == nil
            @desc = "" if @desc == nil
            @repr = "" if @repr == nil
        end

        def set_name(name)
            @name = name
        end

        def set_data_name(data_name)
            @data_name = data_name
        end
        
        def set_data_desc(data_desc)
            @data_desc = data_desc
        end

        def set_repr(repr)
            @repr = repr
        end

        def value
            return @data_value
        end

        def readable
            return @data_name unless @data_name == nil
            return @data_value unless @data_value == nil
            return "N/A"
        end

        def debug
            unless @data_value.blank?
                out = []
                out << "ELEMENT :"
                out << [@code, @data_value].inspect
                out << [@name, @desc, @repr].inspect unless @spec.blank?
                out << [@data_name, @data_desc].inspect if (!@coded_data.blank?)
                return out
            end
        end
    end
end
module EDIFACT
    class Element
        attr_reader :code, :position
        attr_reader :name, :desc, :repr
        attr_reader :data_value, :data_name, :data_desc
        attr_reader :rule

        def initialize(code, version, position, value = "", subset = nil, 
            spec = nil)
            # Define values from given arguments
            @code, @version, @position = code, version, position
            @data_value = value == nil ? "" : value
            @subset, @spec = subset, spec
            # Definite integrity bool and errors list
            @integrity, @errors = false, []
            # Retrieve and apply coded data
            set_coded_data()
            apply_coded_data()
            # Retrieve and apply element specification data
            set_spec()
            apply_element_spec()
            check_against_repr() unless @repr.blank?
        end

        def obfuscate()
            @data_value = @rule.random_string unless @repr.blank?
        end

        def set_coded_data()
            unless $dictionary.is_service_element?(@code, @subset)
                params = [@code, @data_value, @version, @subset]
                @coded_data = $dictionary.coded_data_reference(*params)
            else
                params = [@code, @data_value, nil, @subset]
                @coded_data = $dictionary.service_coded_data_reference(*params)
            end
        end

        def set_spec()
            return unless @spec.blank?
            unless $dictionary.is_service_element?(@code, @subset)
                params = [@code, @version, @subset]
                @spec = $dictionary.element_specification(*params)
            else
                params = [@code, nil, @subset]
                @spec = $dictionary.service_element_specification(*params)
            end
        end

        def check_against_repr
            @rule = Rule.new(@spec)
            if @data_value.blank?
                add_error(MandatoryFieldError.new) unless @rule.conditional?
                return
            end
            unless rule.check_length(@data_value)
                add_error(InvalidLengthError.new(@rule.describe_length))
            end
            unless rule.check_symbols(@data_value)
                add_error(InvalidSymbolsError.new(@rule.describe_symbols))
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

       #def error
       #    return [NoElementError.new, @position] if @errors.blank?
       #    return [@errors.first, @position]
       #end

        def errors
            return @errors.map { |error| [error, @position] }
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
            @data_name = data_name.chomp
        end
        
        def set_data_desc(data_desc)
            @data_desc = data_desc.chomp
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

        def apply_association_code_list(qualifier)
            unless self.blank?
                params = [qualifier, self.code, self.value]
               #puts params.inspect
                data = $dictionary.code_list_lookup(*params)
                unless data.blank?
                    self.set_data_name(data["name"].chomp)
                    self.set_data_desc(data["desc"].chomp)
                    return true
                end
            end
            return false
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
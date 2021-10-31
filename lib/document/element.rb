class Element
    attr_reader :code, :position
    attr_reader :name, :desc, :repr
    attr_reader :data_value, :data_name, :data_desc
    attr_reader :error

    def initialize(code, version, position, value = "")
        @code = code
        @version = version
        @data_value = value == nil ? "" : value
        @position = position
        @error = NoElementError.new
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
    end 

    def is_valid?
        return error == NoElementError.new
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

    def set_data_name(name)
        @data_name = name
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
            out << [@data_name, @data_desc].inspect unless @coded_data.blank?
            return out
        end
    end
end
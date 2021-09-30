class Element
    attr_reader :code

    def initialize(code, version, value = nil)
        @code = code
        @version = version
        @data_value = value
        # Retrieve and apply coded data
        @coded_data = $dictionary.coded_data_reference(code, value, version)
        apply_coded_data()
        # Retrieve and apply element specification data
        @spec = $dictionary.element_specification(code, version)
        apply_element_spec()
    end

    def apply_coded_data
        @data_name = @coded_data.dig("name")
        @data_desc = @coded_data.dig("desc")
    end

    def apply_element_spec
        @name = @spec.dig("name")
        @desc = @spec.dig("desc")
        @repr = @spec.dig("repr")
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
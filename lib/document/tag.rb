module EDIFACT
    TAG_REPR = "a3"

    class Tag
        attr_reader :value, :name, :desc

        def initialize(value, version = nil)
            @value = value
            @name = ""
            @desc = ""
            @version = version
            unless $dictionary.is_service_segment?(@value)
                @spec = $dictionary.segment_specification(@value, @version)
            else
                @spec = $dictionary.service_segment_specification(@value)
            end
            apply_segment_spec()
        end

        def apply_segment_spec
            @name = @spec.dig("name")
            @desc = @spec.dig("desc")
            @desc = @spec.dig("function") if @desc.blank?
            @name = "" if @name.blank?
            @desc = "" if @desc.blank?
        end
    end
end
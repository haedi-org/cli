module EDIFACT
    TAG_REPR = "a3"

    class Tag
        attr_reader :value, :name, :desc

        def initialize(value, version = nil, subset = nil)
            @value = value
            @name = ""
            @desc = ""
            @version = version
            @subset = subset
            set_spec()
            apply_segment_spec()
        end

        def set_spec()
            unless $dictionary.is_service_segment?(@value)
                params = [@value, @version, @subset]
                @spec = $dictionary.segment_specification(*params)
            else
                params = [@value, nil, @subset]
                @spec = $dictionary.service_segment_specification(@value)
            end
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
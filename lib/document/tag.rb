class Tag
    attr_reader :value

    def initialize(value, version = nil)
        @value = value
        @version = version
    end
end
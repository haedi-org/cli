module EDIFACT
    class BAPLIEMessage < Message
        def initialize(lines, interchange_version = '4', chars = DEFAULT_CHARS)
            super(lines, interchange_version, chars)
        end
    end
end
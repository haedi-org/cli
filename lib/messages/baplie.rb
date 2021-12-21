module EDIFACT
    class BAPLIEMessage < Message
        def initialize(lines, interchange_version = '4', chars = DEFAULT_CHARS)
            super(lines, interchange_version, chars)
        end

        def debug
            out = []
            for group in @groups do
                if group.name == "GROUP_5"
                    for segment in group.segments do
                        if segment.is_a?(EQDSegment)
                            out << segment.debug
                        end
                    end
                end
            end
            return out
        end
    end
end
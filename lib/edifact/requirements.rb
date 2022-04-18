module EDIFACT
    class Requirements
        VALID, WARN, ERROR = 0, 1, 2

        def initialize(interchange, data)
            @interchange = interchange
            @data = data
            debug
        end

        def name
            return @data["name"]
        end

        def results
            arr = [] # [Requirement name, Data, Status, Error description]
            message = @interchange.messages.first # Temporary
            for check in @data["checklist"] do
                status, data, error = ERROR, nil, nil
                for t_q in check["qualifiers"] do
                    seg = message.get_segment_by_tag_qualifier(*t_q.split("+"))
                    unless seg == nil
                        status = VALID
                        for code in check["codes"] do
                            data = seg.get_elements_by_code(code).first
                            unless data == nil
                                data = data.readable
                                break
                            end
                        end
                        break
                    end
                end
                case check["datatype"]
                when "GLN"
                    status, error = WARN, "Invalid GLN" unless data&.is_gln?
                when "SSCC"
                    status, error = WARN, "Invalid SSCC" unless data&.is_sscc?
                end
                status, error = ERROR, "Missing field" if data == nil
                arr << [check["name"], data, status, error]
            end
            return arr
        end

        def debug
            out = []
            for name, data, valid, error in results do
                clr = valid == 0 ? :green : :red
                out << "\n#{name}\n- #{valid ? data : error}".colorize(clr)
            end
            return out + ["\n"]
        end
    end
end
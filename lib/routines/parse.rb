def routine_parse(path)
    def message_desc(message, indent = 0)
        a = " " * indent + "Message #{message.type}"
        a += " [#{message.name}]" unless message.name.blank?
        clr = message.is_valid? ? :light_blue : :light_red
        return a.colorize(clr)
    end
    def group_desc(group, indent = 0)
        a = " " * indent + "Group #{group.name}"
        clr = group.is_valid? ? :white : :light_red
        return a.colorize(clr)
    end
    def segment_desc(segment, indent = 0)
        a = " " * indent + "Segment #{segment.tag.value}"
    #   a += " [#{segment.raw}]"
        a += " [#{segment.tag.name}]" unless segment.tag.name.blank?
        unless segment.is_valid?(false)
            a += " \"#{segment.errors(false)[0][0].message}\""
        end
        clr = segment.is_valid? ? :light_cyan : :light_red
        return a.colorize(clr)
    end
    def element_desc(element, indent = 0)
        a = " " * indent + element.name.titleize
        a += " (#{element.code})"
        a += " [#{element.rule.m_c}, #{element.rule.repr}]"
        b = " " * (indent + 2) + element.data_value
        b += " [#{element.data_name}]" unless element.data_name.blank?
        b += " \"#{element.errors[0][0].mesge}\"" unless element.is_valid?
        clr = element.is_valid? ? :light_magenta : :light_red
        if element.has_integrity?
            clr = :light_green
            b = "#{b} #{"\u2713".encode('utf-8')}"
        end
        return a, b.colorize(clr)
    end
    out = []
    interchange = load_interchange(path)
    # Interchange header
    unless interchange.header.blank?
        out << segment_desc(interchange.header, 4)
        for element in interchange.header.flatten do
            out << element_desc(element, 6) unless element.blank?
        end
    end
    # Interchange messages
    for message in interchange.messages do
        out << message_desc(message, 0)
        for group in message.groups do
            out << group_desc(group, 2)
            for segment in group.segments do
                out << segment_desc(segment, 4)
                for element in segment.flatten do
                    out << element_desc(element, 6) unless element.blank?
                end
            end
        end
    end
    # Interchange trailer
    unless interchange.trailer.blank?
        out << segment_desc(interchange.trailer, 4)
        for element in interchange.trailer.flatten do
            out << element_desc(element, 6) unless element.blank?
        end
    end
    return out
end

def routine_html_parse(path)
    out = []
    interchange = load_interchange(path)
    out << html_reference_table(interchange)
    return out
end
def routine_help
    out = []
    out << print_header()
    out << File.readlines(USAGE_PATH)
    return out
end

def routine_info(lines)
    out = []
    return out
end

def routine_parse(lines)
    out = []
    document = Document.new(lines)
    for segment in document.segments do
        out << ["", segment.raw, segment.tag.name]
        for element in segment.flatten do
            unless element.blank?
                out << [
                    element.code,
                    element.position.join("_"),
                    element.data_value,
                ].inspect
            end
        end
    end
    return out
end

def routine_html_parse(lines)
    out = []
    document = Document.new(lines)
    out << html_document_information(document)
    return out
end

def routine_debug(lines)
    out = []
    document = Document.new(lines)
    for segment in document.segments do
        # DTM testing
        if segment.is_a?(DTMSegment)
            out << segment.raw
            out << segment.version
            out << segment.date_time.data_name
        end
    end
    return out
end

def routine_structure(lines)
    out = []
    return out
end

def routine_timeline(lines)
    out = []
    return out
end
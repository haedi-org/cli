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

def routine_html_info(lines)
    out = []
    #out << html_document_information(document)
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
    out << html_reference_table(document)
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

def routine_html_debug(lines)
    out = []
    document = Document.new(lines)
    out << html_debug(document)
    return out
end

def routine_collection(paths)
    out = []
    # Check if path is file or dir
    if File.directory?(paths.first)
        paths.map! do |path|
            path = path.gsub("\\", "/")
            Dir[path + "*"]
        end
    end
    # Parse paths
    for path in paths.flatten.compact do
        if File.file?(path)
            filename = File.basename(path)
            begin
                lines = File.readlines(path)
                document = Document.new(lines)
                message = document.message_type
                version = document.version
                throw if message.blank? or version.blank?
                out << [filename, message, version].join("\t")
            rescue
                out << [filename, "Error"].join("\t")
            end
        end
    end
    return out
end

def routine_html_collection(paths)
    out = []
    table = []
    # Check if path is file or dir
    if File.directory?(paths.first)
        paths.map! do |path|
            path = path.gsub("\\", "/")
            Dir[path + "*"]
        end
    end
    # Parse paths
    for path in paths.flatten.compact do
        if File.file?(path)
            filename = File.basename(path)    
            begin
                lines = File.readlines(path)
                document = Document.new(lines)
                message = document.message_type
                version = document.version
                table << [
                    filename, message, version
                ]
            rescue
                # Could not parse file
            end
        end
    end
    out << html_table(table)
    return out
end
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
    for segment in document.segments.compact do
        out << ["", segment.raw, segment.tag.name]
        for element in segment.flatten do
            unless element.blank?
                arr = [
                    element.code,
                    element.position.join("_"),
                    element.data_value
                ]
                arr << element.errors.first.message unless element.is_valid?
                out << arr.inspect
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
    document = Document.new(lines)
    timeline = document.timeline
    out << ascii_table(timeline, [40, 40]) unless timeline.blank?
    return out
end

def routine_html_timeline(lines)
    out = []
    document = Document.new(lines)
    timeline = document.timeline
    # Timeline
    timeline.map! do |event, time|
        [
            # Marker
            String.new.html("div", :cl => "timeline-marker"),
            # Content
            [
                time.html("p", :cl => "heading"), 
                event.html("p")
            ].join.html("div", :cl => "timeline-content")
            # 
        ].join.html("div", :cl => "timeline-item")
    end
    # Tags
    start_tag, end_tag = ["Start", "End"].map! do |caption|
        caption
            .html("span", :cl => "tag is-medium is-primary")
            .html("header", :cl => "timeline-header")
    end
    # Assemble
    out << [start_tag, timeline, end_tag]
        .flatten.join.html("div", 
            :cl => "timeline is-centered",
            :st => "padding-top: 32px"
    )
    return out
end

def routine_debug(lines)
    out = []
    document = Document.new(lines)
    out << document.controlling_agency
    out << document.association_assigned_code
    #for segment in document.segments do
    #    # DTM testing
    #    if segment.is_a?(DTMSegment)
    #        out << segment.raw
    #        out << segment.version
    #        out << segment.date_time.data_name
    #    end
    #end
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
    table = []
    # Check if path is file or dir
    if File.directory?(paths.first)
        out << "―" * 48
        paths.map! do |path|
            out << path
            path = path.gsub("\\", "/")
            Dir[path + "/*"]
        end
        out << "―" * 48
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
                table << [
                    filename,
                    message, 
                    version,
                ]
            rescue
                table << [
                    filename, 
                    "N/A".ljust(12, " ").colorize(:light_red), 
                    "N/A".ljust(12, " ").colorize(:light_red),
                ]
            end
        end
    end
    out << ascii_table(table, [32, 12, 12])
    out << "―" * 48
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

def ascii_table(data, widths = Array.new(99) { 16 })
    return data.map { |row|
        row.map.with_index { |cell, index|
            cell.ljust(widths[index], " ")
        }.join
    }.join("\n")
end
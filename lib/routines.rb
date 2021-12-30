# 0x6a j ┘ 0x74 t ├
# 0x6b k ┐ 0x75 u ┤
# 0x6c l ┌ 0x76 v ┴
# 0x6d m └ 0x77 w ┬
# 0x6e n ┼ 0x78 x │
# 0x71 q ─

$previous_path = nil
$previous_interchange = nil

def load_interchange(path)
    unless path == $previous_path
        interchange = EDIFACT::Interchange.new(path)
        $previous_path, $previous_interchange = path, interchange
    else
        interchange = $previous_interchange
    end
    return interchange
end

def routine_help
    out = []
    out << print_header()
    out << File.readlines(USAGE_PATH)
    return out
end

def routine_info(path)
    out = []
    return out
end

def routine_html_info(path)
    out = []
    #out << html_document_information(document)
    return out
end

def routine_parse(path)
    out = []
    interchange = load_interchange(path)
    for message in interchange.messages do
        out << message.type
        for group in message.groups do
            out << "Group #{group.name}"
            for segment in group.segments do
                out << "  Segment #{segment.tag.value}"
                for element in segment.flatten do
                    unless element.blank?
                        out << "    #{element.name.titleize}"
                        line = "      #{element.data_value}"
                        unless element.data_name.blank?
                            line += " [#{element.data_name}]"
                        end
                        out << line
                        #arr = [
                        #    element.code,
                        #    element.name.titleize,
                        #    element.position.join("_"),
                        #    element.data_value,
                        #    element.repr,
                        #]
                        #unless element.is_valid?
                        #    arr << element.errors.first.message
                        #end
                        ##arr << TICK_CHARACTER if element.has_integrity?
                        #out << arr.inspect
                    end
                end
            end
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

def routine_structure(path)
    out = []
    interchange = load_interchange(path)
    messages = interchange.messages
    messages.compact.each_with_index do |message, m_i|
        out << "#{message.type} (\##{message.reference})"
        groups = message.groups
        groups.each_with_index do |group, g_i|
            g_branch = (g_i == groups.length - 1 ? " └─ " : " ├─ ")
            out << g_branch + group.name
            segments = group.segments
            segments.each_with_index do |segment, s_i|
                g_branch = (g_i == groups.length - 1 ? "    " : " │  ")
                s_branch = (s_i == segments.length - 1 ? " └─ " : " ├─ ")
                caption = segment.tag.value + ": " + segment.tag.name
                out << g_branch + s_branch + caption
            end
        end
    end
    return out
end

def routine_timeline(path)
    out = []
    interchange = load_interchange(path)
    interchange.messages.each do |message|
        out << "#{message.type} (\##{message.reference})"
        timeline = message.timeline
        timeline.each_with_index do |data, t_i|
            name, date = data
            t_branch = (t_i == timeline.length - 1 ? " └─ " : " ├─ ")
            out << t_branch + name
            t_branch = (t_i == timeline.length - 1 ? "    " : " │  ")
            n_branch = " └─ "
            out << t_branch + n_branch + date
        end
    end
    #for timeline in timelines do
    #    out << ascii_table(timeline, [40, 40]) unless timeline.blank?
    #end
    return out
end

def routine_html_timeline(path)
    out = []
    interchange = load_interchange(path)
    out << html_timeline(interchange)
    return out
end

def routine_debug(path)
    out = []
    interchange = load_interchange(path)
    for message in interchange.messages do
        if message.is_a?(EDIFACT::DESADVMessage)
            out << message.debug
        end
    end
    # Print processing times
    load_time = sprintf("%.2f", interchange.load_time * 1000).to_s + "ms"
    process_time = sprintf("%.2f", interchange.process_time * 1000).to_s + "ms"
    out << "Finished in #{process_time} (files took #{load_time} to load)"
    #document = Document.new(lines, path)
    #out << edi_to_xml(document)
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

def routine_html_debug(path)
    out = []
    interchange = load_interchange(path)
    out << html_debug(interchange)
    return out
end

def routine_bayplan(path)
    out = []
    interchange = load_interchange(path)
    out << ascii_bayplan(interchange)
    return out
end

def routine_html_bayplan(path)
    out = []
    interchange = load_interchange(path)
    out << html_bayplan(interchange)
    return out
end

def routine_collection(paths, path)
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
                document = Document.new(lines, path)
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
                document = Document.new(lines, path)
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
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
    out = [""]
    version = File.readlines(VERSION_PATH).first.chomp
    out << File.readlines(USAGE_PATH).map { |l| l.gsub("VERSION", version) }
    return out
end

def routine_info(path, interchange = nil)
    out = []
    interchange = load_interchange(path) if interchange == nil
    # Message specific outputs
    for message in interchange.messages do
        # out << message.to_json if message.type == "DESADV"
    end
    out << ""
    # File info
    out << "File path = #{path}"
    out << "File size = #{File.size(path).to_filesize}"
    out << ""
    # Message info
    for message in interchange.messages do
        out << [
            "Message type = #{message.type}",
            "Message version = #{message.version}",
            "Subset = #{message.subset == nil ? "none" : message.subset}",
            "Association assigned code = #{message.association_assigned_code}",
            "Controlling agency = #{message.controlling_agency}",
        ]
    end
    out << ""
    # Dictionary information
    used = $dictionary.code_lists_used
    used_count = $dictionary.code_lists_used_count
    read_count = $dictionary.read_count
    out << "Dictionary read count = #{read_count}"
    unless used_count == 0
        out << "3rd-party code lists (#{used_count})\n- #{used.join("\n- ")}"
    end
    out << ""
    # Errors
    errs = interchange.errors.map { |e, l| "[#{l.join(":")}] #{e.message}" }
    unless errs.length == 0
        out << "Errors (#{errs.length})\n- #{errs.first(10).join("\n- ")}"
            .colorize(:light_red)
        out << ""
    end
    return out
end

def routine_html_info(path)
    out = []
    interchange = load_interchange(path)
    out << html_info(interchange)
    return out
end

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
        a += " [#{element.rule.m_c}]"
        b = " " * (indent + 2) + element.data_value
        b += " [#{element.data_name}]" unless element.data_name.blank?
        b += " \"#{element.errors[0][0].message}\"" unless element.is_valid?
        clr = element.is_valid? ? :light_magenta : :light_red
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
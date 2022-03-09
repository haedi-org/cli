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
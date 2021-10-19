OPT_DATA = {
    :info      => ["-i", "--info"],
    :parse     => ["-p", "--parse"],
    :debug     => ["-d", "--debug"],
    :structure => ["-s", "--structure"],
    :timeline  => ["-t", "--timeline"],
    :headless  => ["-l", "--headless"],
    :help      => ["-h", "--help"],
    :html      => ["--html"],
}

QUIT_COMMAND = "q"
STDOUT_FINISH = "END"

def extract_paths(arr)
    paths = arr.map { |arg| File.file?(arg) ? arg : nil }
    return paths.compact
end

def extract_tags(arr)
    tags = arr.map { |arg| arg[0] == "-" ? arg : nil }.compact
    return tags.compact
end

$opts = extract_tags(ARGV)
$paths = extract_paths(ARGV)

def opt?(key)
    a, b = OPT_DATA[key]
    return true if (a != nil) && $opts.include?(a)
    return true if (b != nil) && $opts.include?(b)
    return false
end

def routine_help
    out = []
    out << print_header
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

def process_paths(paths)
    out = []
    for path in paths do
        lines = read_document(path)
        out << routine_info(lines)       if opt?(:info)
        out << routine_parse(lines)      if opt?(:parse)
        out << routine_debug(lines)      if opt?(:debug)
        out << routine_structure(lines)  if opt?(:structure)
        out << routine_timeline(lines)   if opt?(:timeline)
        out << routine_html_parse(lines) if opt?(:html) && opt?(:parse)
    end
    return out
end

def print_out(out)
    if opt?(:html)
        print out.flatten.join
        print STDOUT_FINISH
    else
        print out.flatten.join("\n")
    end
end

out = []

if opt?(:help) or $opts.empty?
    out << routine_help()
    print_out(out)
    exit
end

if opt?(:headless)
    $stdout.sync = true
    begin
        until false
            input = STDIN.gets.chomp
            clear_stdin()
            quit_notty() if input == QUIT_COMMAND
            unless input == nil
                $paths = extract_paths(input.words)
                $opts  = extract_tags(input.words)
                unless $paths.empty?
                    print_out(out)
                end
            end
        end
    rescue => exception
        out += [exception.message, exception.backtrace]
        print_out(out)
    end
else
    out = process_paths($paths)
    print_out(out)
end
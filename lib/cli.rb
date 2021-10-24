OPT_DATA = {
    :info       => ["-i", "--info"],
    :parse      => ["-p", "--parse"],
    :debug      => ["-d", "--debug"],
    :structure  => ["-s", "--structure"],
    :timeline   => ["-t", "--timeline"],
    :headless   => ["-l", "--headless"],
    :collection => ["-c", "--collection"],
    :help       => ["-h", "--help"],
    :html       => ["--html"],
}

QUIT_COMMAND = "q"
STDOUT_FINISH = "END"

def clear_stdin()
    $stdin.getc while $stdin.ready?
end

def quit_notty()
    File.open(RECENT_LOG_PATH, 'w+') { |f| f.puts Time.now.to_s }
    exit
end

def extract_paths(arr)
    paths = arr.map { |arg| File.file?(arg) ? arg : nil }
    return paths.compact
end

def extract_tags(arr)
    tags = arr.map { |arg| arg[0] == "-" ? arg : nil }.compact
    return tags.compact
end

def opt?(key)
    a, b = OPT_DATA[key]
    return true if (a != nil) && $opts.include?(a)
    return true if (b != nil) && $opts.include?(b)
    return false
end

def no_opt?(key)
    return (!opt?(key))
end

def process_paths(paths)
    out = []
    # Routines on multiple files
    if opt?(:collection)
        return routine_collection(paths) if no_opt?(:html)
        return routine_html_collection(paths) if opt?(:html)
    end
    # Routines on singular files
    for path in paths do
        lines = read_document(path)
        out << routine_info(lines)       if opt?(:info) && no_opt?(:html)
        out << routine_html_info(lines)  if opt?(:info) && opt?(:html)
        out << routine_parse(lines)      if opt?(:parse) && no_opt?(:html)
        out << routine_html_parse(lines) if opt?(:parse) && opt?(:html)
        out << routine_debug(lines)      if opt?(:debug) && no_opt?(:html)
        out << routine_html_debug(lines) if opt?(:debug) && opt?(:html)
        out << routine_structure(lines)  if opt?(:structure)
        out << routine_timeline(lines)   if opt?(:timeline)
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

$opts = extract_tags(ARGV)
$paths = extract_paths(ARGV)

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
                    out << process_paths($paths)
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
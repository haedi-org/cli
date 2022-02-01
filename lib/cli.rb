OPT_DATA = {
    :info       => ["-i", "--info"],
    :parse      => ["-p", "--parse"],
    :debug      => ["-d", "--debug"],
    :structure  => ["-s", "--structure"],
    :timeline   => ["-t", "--timeline"],
    :headless   => ["-l", "--headless"],
    # TODO: Generalise to a visual output
    :bayplan    => ["--bayplan"],
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

def extract_dirs(arr)
    dirs = arr.map { |arg| File.directory?(arg) ? arg : nil }
    return dirs.compact
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

def process_paths(paths, dirs)
    out = []
    # Routines on multiple files
    if opt?(:collection)
        arg = dirs.empty? ? paths : dirs
        return routine_collection(arg) if no_opt?(:html)
        return routine_html_collection(arg) if opt?(:html)
    end
    # Routines on singular files
    for path in paths do
        arg = [path]
        out << routine_info(*arg)          if opt?(:info) && no_opt?(:html)
        out << routine_html_info(*arg)     if opt?(:info) && opt?(:html)
        out << routine_parse(*arg)         if opt?(:parse) && no_opt?(:html)
        out << routine_html_parse(*arg)    if opt?(:parse) && opt?(:html)
        out << routine_debug(*arg)         if opt?(:debug) && no_opt?(:html)
        out << routine_html_debug(*arg)    if opt?(:debug) && opt?(:html)
        out << routine_structure(*arg)     if opt?(:structure)
        out << routine_timeline(*arg)      if opt?(:timeline) && no_opt?(:html)
        out << routine_html_timeline(*arg) if opt?(:timeline) && opt?(:html)
        out << routine_bayplan(*arg)       if opt?(:bayplan) && no_opt?(:html)
        out << routine_html_bayplan(*arg)  if opt?(:bayplan) && opt?(:html)
    end
    return out
end

def print_out(out)
    if opt?(:html)
        print out.flatten.join
        print STDOUT_FINISH
    else
        puts out.flatten
    end
end

$paths = extract_paths(ARGV)
$dirs  = extract_dirs(ARGV)
$opts  = extract_tags(ARGV)
$opts << "--collection" unless $dirs.empty?

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
                $dirs = extract_dirs(input.words)
                $opts = extract_tags(input.words)
                $opts << "--collection" unless $dirs.empty?
                unless $paths.empty? && $dirs.empty?
                    out << process_paths($paths, $dirs)
                    print_out(out)
                    out = []
                end
            end
        end
    rescue => exception
        out += [exception.message, exception.backtrace]
        print_out(out)
        out = []
    end
else
    out = process_paths($paths, $dirs)
    print_out(out)
end

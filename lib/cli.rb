OPT_DATA = {
    :info      => ["-i", "--info"],
    :parse     => ["-p", "--parse"],
    :debug     => ["-d", "--debug"],
    :structure => ["-s", "--structure"],
    :timeline  => ["-t", "--timeline"],
    :headless  => ["-l", "--headless"],
    :xml       => ["--xml"],
    :json      => ["--json"],
    :csv       => ["--csv"],
    # TODO: Generalise to a visual output
    :bayplan   => ["--bayplan"],
    :checklist => ["-c", "--checklist"],
    :help      => ["-h", "--help"],
    :html      => ["--html"],
    :verbose   => ["-v", "--verbose"],
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

def extract_edi_paths(arr)
    return extract_paths(arr).select do |path|
        File.extname(path).upcase != ".JSON"
    end
end

def extract_json_paths(arr)
    return extract_paths(arr).select do |path|
        File.extname(path).upcase == ".JSON"
    end
end

def opt?(key)
    OPT_DATA[key].compact.each { |k| return true if $opts.include?(k) }
    return false
end

def no_opt?(key)
    return (!opt?(key))
end

def process_paths(edi_paths, json_paths, dirs)
    out = []
    # Routines on multiple files
#   if opt?(:collection)
#       arg = dirs.empty? ? paths : dirs
#       return routine_collection(arg) if no_opt?(:html)
#       return routine_html_collection(arg) if opt?(:html)
#   end
    # Routines on singular files
    for edi_path in edi_paths do
        # Required JSON file
        if opt?(:checklist)
            unless json_paths.empty?
                arg = [edi_path, json_paths.first]
                unless opt?(:html)
                    out << routine_checklist(*arg)
                else
                    out << routine_html_checklist(*arg)
                end
            end
        end
        # No required JSON file
        arg = [edi_path]
        unless opt?(:html)
            out << routine_info(*arg)       if opt?(:info)
            out << routine_parse(*arg)      if opt?(:parse)
            out << routine_debug(*arg)      if opt?(:debug)
            out << routine_structure(*arg)  if opt?(:structure)
            out << routine_timeline(*arg)   if opt?(:timeline)
            out << routine_bayplan(*arg)    if opt?(:bayplan)
            out << routine_morph_xml(*arg)  if opt?(:xml)
            out << routine_morph_json(*arg) if opt?(:json)
            out << routine_morph_csv(*arg)  if opt?(:csv)
        else
            out << routine_html_info(*arg)       if opt?(:info)
            out << routine_html_parse(*arg)      if opt?(:parse)
            out << routine_html_debug(*arg)      if opt?(:debug)
            out << routine_html_timeline(*arg)   if opt?(:timeline)
            out << routine_html_bayplan(*arg)    if opt?(:bayplan)
            out << routine_html_morph_xml(*arg)  if opt?(:xml)
            out << routine_html_morph_json(*arg) if opt?(:json)
            out << routine_html_morph_csv(*arg)  if opt?(:csv)
        end
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

def log(str, clr = :white, prefix = "INFO")
    puts "[#{prefix}] #{str.colorize(clr == nil ? :white : clr)}" if VERBOSE
end

$edi_paths = extract_edi_paths(ARGV)
$json_paths = extract_json_paths(ARGV)
$dirs = extract_dirs(ARGV)
$opts = extract_tags(ARGV)
#$opts << "--collection" unless $dirs.empty?

VERBOSE = opt?(:verbose)

def help_break(out = [])
    out << routine_help()
    print_out(out)
    exit
end
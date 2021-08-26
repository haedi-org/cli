HELP_OPTS      = ["-h", "--help"]
PARSE_OPTS     = ["-p", "--parse"]
UNIT_TEST_OPTS = ["-u", "--unit"]
DEBUG_OPTS     = ["-d", "--debug"]
INFO_OPTS      = ["-i", "--info"]
STRUCTURE_OPTS = ["-s", "--structure"]
TIMELINE_OPTS  = ["-t", "--timeline"]
HEADLESS_OPTS  = ["-l", "--headless"]
EDICATE_OPTS   = ["-e", "--edicate"]

QUIT_COMMAND = 'q'

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

def opt?(a = nil, b = nil)
    return true if (a != nil) && $opts.include?(a)
    return true if (b != nil) && $opts.include?(b)
    return false
end

if $opts.empty? or ($paths.empty? && !opt?(*HEADLESS_OPTS)) or opt?(*HELP_OPTS)
    out = []
    out << print_header
    out << File.readlines(USAGE_PATH)
    puts out.flatten.join
    return
end

# UNIT TEST
if opt?(*UNIT_TEST_OPTS)
    out = []
    out << print_header
    tests = $paths.map.with_index { |a, i| [nil, a, true] }
    out << unit_test(tests)
    print out.flatten.join("\n")
    return
end

def process_paths(paths)
    out = []
    for path in paths do
        begin
            lines = read_document(path)
            # DEBUG
            if opt?(*DEBUG_OPTS)
                raise InvalidDocumentError.new unless valid_document?(lines)
                document = Document.new(lines)
                for line in document.lines do
                    out << line.debug_rules
                end
            end
            # INFO
            if opt?(*INFO_OPTS)
                raise InvalidDocumentError.new unless valid_document?(lines)
                document = Document.new(lines)
                unless opt?(*EDICATE_OPTS)
                    for key, value in document.info do
                        out << [key.to_s.unkey.rpad(48), value].join
                    end
                else
                    out << html_document_information(document)
                end
            end
            # PARSE
            if opt?(*PARSE_OPTS)
                raise InvalidDocumentError.new unless valid_document?(lines)
                document = Document.new(lines)
                unless opt?(*EDICATE_OPTS)
                    for group in document.rows do
                        for loc, row in group do
                            code, title, value, data, desc = row
                            data = data + " <#{value}>" unless data == value
                            for cell in [code, title, data] do
                                width = cell == row.first ? 16 : 56
                                out << cell.rpad(width)
                            end
                            out << "\n"
                        end
                        out << "\n"
                    end
                else
                    out << html_reference_table(document)
                end
            end
            # STRUCTURE
            if opt?(*STRUCTURE_OPTS)
                raise InvalidDocumentError.new unless valid_document?(lines)
                structure = Document.new(lines).structure
                out << structure.debug unless structure == nil
            end
            # TIMELINE
            if opt?(*TIMELINE_OPTS)
                raise InvalidDocumentError.new unless valid_document?(lines)
                out << "TODO : Timeline output"
            end
        rescue InvalidDocumentError => exception
            out << ""
            out << unit_test([[nil, path, true]])
        rescue => exception
            unless opt?(*EDICATE_OPTS)
                out += [exception.message, exception.backtrace]
            else
                out << html_error(exception)
            end
        end
    end
    return out
end

def clear_stdin()
    $stdin.getc while $stdin.ready?
end

def quit_notty()
    File.open(RECENT_LOG_PATH, 'w+') { |f| f.puts Time.now.to_s }
    exit
end

if opt?(*HEADLESS_OPTS)
    $stdout.sync = true
    begin
        until false
            input = STDIN.gets.chomp
            clear_stdin()
            quit_notty() if input == QUIT_COMMAND
            unless input == nil
                $paths = extract_paths(input.words)
                $opts = extract_tags(input.words)
                unless $paths.empty?
                    print process_paths($paths).flatten.join
                    print "END" if opt?(*EDICATE_OPTS)
                end
            end
        end
    rescue => exception
        out += [exception.message, exception.backtrace]
        print out.flatten.join("\n")
        print "END" if opt?(*EDICATE_OPTS)
    end
else
    out = process_paths($paths)
    print out.flatten.join("\n")
    print "END" if opt?(*EDICATE_OPTS)
end
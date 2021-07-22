HELP_PATH = "./help.txt"

HELP_OPTS      = ["-h", "--h"]
TEST_OPTS      = ["-t", "--test"]
DEBUG_OPTS     = ["-d", "--debug"]
STRUCTURE_OPTS = ["-s", "--structure"]
MEDIAN_OPTS    = ["-m", "--median"]

$opts = ARGV.map { |arg| arg[0] == "-" ? arg : nil }.compact
$paths = ARGV.map { |arg| File.file?(arg) ? arg : nil }.compact

def opt?(a = nil, b = nil)
    return true if (a != nil) && $opts.include?(a)
    return true if (b != nil) && $opts.include?(b)
    return false
end

if $opts.empty? or $paths.empty? or opt?(*HELP_OPTS)
    header = "#{TITLE}#{" " * 16}#{VERSION}"
    puts "\n", (b = "-" * header.length), header, b, "\n"
    puts File.readlines(HELP_PATH)
    return
end

# TEST
if opt?(*TEST_OPTS)
    tests = $paths.map.with_index { |a, i| [nil, a, true] }
    unit_test(tests)
    return
end

for path in $paths do
    begin
        lines = read_document(path)
        # DEBUG
        if opt?(*DEBUG_OPTS)
            if valid_document?(lines)
                document = Document.new(lines)
                document.debug
            end
        end
        # STRUCTURE
        if opt?(*STRUCTURE_OPTS)
            if valid_document?(lines)
                document = Document.new(lines)
                document.structure.debug
            end
        end
    rescue => exception
        unless opt?(*MEDIAN_OPTS)
            puts exception.message, exception.backtrace
        else
            html_error(exception)
        end
    end
end
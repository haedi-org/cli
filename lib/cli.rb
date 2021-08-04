HELP_PATH = "./help.txt"

HELP_OPTS      = ["-h", "--help"]
PARSE_OPTS     = ["-p", "--parse"]
UNIT_TEST_OPTS = ["-u", "--unit"]
DEBUG_OPTS     = ["-d", "--debug"]
STRUCTURE_OPTS = ["-s", "--structure"]
TIMELINE_OPTS  = ["-t", "--timeline"]
EDICATE_OPTS   = ["-e", "--edicate"]

$opts = ARGV.map { |arg| arg[0] == "-" ? arg : nil }.compact
$paths = ARGV.map { |arg| File.file?(arg) ? arg : nil }.compact

def opt?(a = nil, b = nil)
    return true if (a != nil) && $opts.include?(a)
    return true if (b != nil) && $opts.include?(b)
    return false
end

if $opts.empty? or $paths.empty? or opt?(*HELP_OPTS)
    print_header
    puts File.readlines(HELP_PATH)
    return
end

# UNIT TEST
if opt?(*UNIT_TEST_OPTS)
    print_header
    tests = $paths.map.with_index { |a, i| [nil, a, true] }
    unit_test(tests)
    return
end

for path in $paths do
    begin
        lines = read_document(path)
        # DEBUG
        if opt?(*DEBUG_OPTS)
            raise InvalidDocumentError.new unless valid_document?(lines)
            document = Document.new(lines)
           #for line in document.lines do
           #    puts line.date if line.tag.value == "DTM"
           #end
            document.debug
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
                            print cell.ljust(cell == row.first ? 16 : 56, " ")
                        end
                        print "\n"
                    end
                    print "\n"
                end
            else
                html_reference_table(document)
            end
        end
        # STRUCTURE
        if opt?(*STRUCTURE_OPTS)
            raise InvalidDocumentError.new unless valid_document?(lines)
            structure = Document.new(lines).structure
            structure.debug unless structure == nil
        end
        # TIMELINE
        if opt?(*TIMELINE_OPTS)
            raise InvalidDocumentError.new unless valid_document?(lines)
            puts "TODO : Timeline output"
        end
    rescue InvalidDocumentError => exception
        puts ""
        unit_test([[nil, path, true]])
    rescue => exception
        unless opt?(*EDICATE_OPTS)
            puts exception.message, exception.backtrace
        else
            html_error(exception)
        end
    end
end
OPT_DATA = {
    :unit_test => ["-u", "--unit"],
    :info      => ["-i", "--info"],
    :parse     => ["-p", "--parse"],
    :debug     => ["-d", "--debug"],
    :structure => ["-s", "--structure"],
    :timeline  => ["-t", "--timeline"],
    :headless  => ["-l", "--headless"],
    :html      => ["-h", "--html"],
}

@options = {}


parser.parse!
puts @options.inspect
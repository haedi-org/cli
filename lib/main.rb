TITLE = "CLI for EDI parsing, validation and manipulation"
AUTHOR = "Louis Machin"
VERSION = "v0.1.0"

def print_header
    header = "#{TITLE}#{" " * 16}#{VERSION}"
    puts "\n", (b = "-" * header.length), header, b, "\n"
end

ENV["OCRA_EXECUTABLE"].tap { |d| Dir.chdir(File.dirname(d)) if d }

WITHOUT_CLI = false
require_relative './include.rb'
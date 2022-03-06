AUTHOR = "Louis Machin"

ENV["OCRA_EXECUTABLE"].tap { |d| Dir.chdir(File.dirname(d)) if d }

WITHOUT_CLI = false
require_relative './include.rb'
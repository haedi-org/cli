# ROOT_DIR = __dir__
require_relative './lib/paths.rb'

task :default do
    puts "build\tbuild executable using ocra"
    puts "test\trun unit tests"
end

task :build do
    params = [
        RUN_PATH,
        "--output", OUTPUT_PATH,
        "--console",
        "--gemfile", "Gemfile"
    ]
    puts `ocra #{params.join(" ")}`
end

task :test do
    paths = Dir[TEST_MESSAGE_PATH + "*.edi"]
    puts `ruby #{RUN_PATH} --unit #{paths.join(" ")}`.force_encoding(Encoding::UTF_8)
end
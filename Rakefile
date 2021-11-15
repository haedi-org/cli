# ROOT_DIR = __dir__
require_relative './lib/paths.rb'

task :default do
    puts "build\tbuild executable using ocra"
    puts "test\trun rspec"
end

task :build do
    source = (Dir["./lib/**/*.rb"] - [RUN_PATH]).join(" ")
    params = [
        RUN_PATH, source,
        "--output", OUTPUT_PATH,
        "--console",
        "--gemfile", "Gemfile"
    ]
    puts `ocra #{params.flatten.join(" ")}`
end

task :test do
    params = [
        RSPEC_PATH,
        "--tty", "--color",
        "--format", "documentation"
    ]
    puts `rspec #{params.join(" ")}`
end

task :test_datatypes do
    params = [
        RSPEC_DATATYPES_PATH,
        "--tty", "--color",
        "--format", "documentation"
    ]
    puts `rspec #{params.join(" ")}`
end
# ROOT_DIR = __dir__
require_relative './lib/paths.rb'

task :default do
    puts "build\tbuild executable using ocra"
    puts "test\trun rspec"
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
    params = [
        RSPEC_PATH,
        "--tty", "--color",
        "--format", "documentation"
    ]
    puts `rspec #{params.join(" ")}`
end
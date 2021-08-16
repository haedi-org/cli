require './lib/paths.rb'

task :default do
    puts "build\tbuild executable using ocra"
    puts "test\trun unit tests"
end

task :build do
    puts `ocra #{RUN_PATH} --output #{OUTPUT_PATH} --gemfile Gemfile --gem-minimal`
end

task :test do
    paths = Dir[TEST_MESSAGE_PATH + "*.edi"]
    puts `ruby #{RUN_PATH} --unit #{paths.join(" ")}`.force_encoding(Encoding::UTF_8)
end
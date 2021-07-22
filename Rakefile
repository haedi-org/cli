require './lib/paths.rb'

TEST_MESSAGE_PATH = "./data/messages/tests/"

task :default do
    puts "build\tbuild executable using ocra"
    puts "test\trun unit tests"
end

task :build do
    puts `ocra edi.rb --output #{OUTPUT_PATH} --gemfile Gemfile --gem-minimal`
end

task :test do
    paths = Dir[TEST_MESSAGE_PATH + "/*"]
    puts `ruby edi.rb --unit #{paths.join(" ")}`.force_encoding(Encoding::UTF_8)
end
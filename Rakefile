require './lib/paths.rb'

task :default do
    puts "build\tbuild executable using ocra"
    puts "test\trun unit tests"
end

task :build do
    puts `ocra edi.rb --output #{OUTPUT_PATH} --gemfile Gemfile --gem-minimal`
end

task :example do
    puts `ruby edi.rb --refs #{MESSAGE_PATH}/samples/DESADV_D01B_ecosio.edi`
end

task :test do
    paths = ARGV.map { |arg| File.file?(arg) ? arg : nil }.compact
    puts `ruby edi.rb --test #{paths.join(" ")}`
end

task :debug do
    paths = ARGV.map { |arg| File.file?(arg) ? arg : nil }.compact
    puts `ruby edi.rb --debug #{paths.join(" ")}`
end
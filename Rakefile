require_relative './lib/paths.rb'
WITHOUT_CLI = true

task :default do
    puts "build\t\tbuild executable using ocra"
    puts "test\t\trun rspec"
    puts "datatypes\trun datatypes rspec"
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

task :datatypes do
    params = [
        RSPEC_DATATYPES_PATH,
        "--tty", "--color",
        "--format", "documentation"
    ]
    puts `rspec #{params.join(" ")}`
end

task :debug do
    hash = {
        "2" => { "a" => 1 },
        "1" => { "b" => 2 },
        "12" => { "c" => 3 },
        "7" => { "c" => 3 }
    }
    arr = hash.map { |k, v| k.to_i }.sort.map { |i| "SG#{i}" }
    puts arr.inspect
end

task :repr do
    require_relative './lib/include.rb'
    rule = EDIFACT::Rule.new({ "repr" => "an..9" })
    (0..10).each do
        puts rule.random_string
    end
end
# ROOT_DIR = __dir__
require_relative './lib/paths.rb'

task :formtest do
    require './lib/forms/form.rb'
    form = Form::Page.new(:name => 'TEST', :length => 30)
    form.add_box(10, 20, 30, 40)
    form.add_text(20, 20, 'BLAH', 40, 20)
    form.add_barcode(30, 30, '12345')
    puts "ZPL:", form.to_zpl
end

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
    require './lib/datatypes.rb'
    puts "SUDU1234569".is_iso_6346_container_code?
    puts "OOLU1996346".is_iso_6346_container_code?
    puts "CMBU2366346".is_iso_6346_container_code?
end

task :row_order do
    arr = ["00","01","02","03","04","05","06","07","08","09","10","11","12"]
    evens = arr.select { |n| n.to_i % 2 == 0 }
    odds  = arr.select { |n| n.to_i % 2 == 1 }
    arr = evens.sort.reverse + odds.sort
    puts arr
end
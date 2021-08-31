Reference = Struct.new(:value, :ref, :desc, :code)
# TODO : Move away from Reference struct

Definition = Struct.new(:code, :definition)
#Element = Struct.new(:loc, :code, :title, :value, :desc, :ref, :coded)
Version = Struct.new(:number, :release, :ref, :code, :title)
Qualifier = Struct.new(:code, :value, :reference, :definition)
Tag = Struct.new(:loc, :value, :title, :definition)

EMPTY_STRING = ""
NULL_VALUES = [nil, [], EMPTY_STRING]

$code_lists = {}
Dir["#{CODE_PATH}/*.json"].each do |path|
    file = File.open(path)
    version = File.basename(path, ".json")
    $code_lists[version] = JSON.load(file)
    file.close
end

$element_dictionary = {}
CSV.foreach(EDIFACT_ELEMENTS_PATH, 'rb:utf-8') do |line|
    code, definition = line[0], line[1].chomp
    $element_dictionary[code] = Definition.new(code, definition)
end
CSV.foreach(EDIFACT_SERVICE_ELEMENTS_PATH, 'rb:utf-8') do |line|
    code, definition = line[0], line[1].chomp
    $element_dictionary[code] = Definition.new(code, definition)
end


def define_element_code(code)
    if $element_dictionary.include?(code)
        return $element_dictionary[code]
    else
        return Definition.new(code, code)
    end
end

def lookup_structure(message, version)
    path = "#{STRUCTURE_PATH}/#{message}_#{version}.json"
    path = "#{STRUCTURE_PATH}/#{message}.json" unless File.file?(path)
    json = read_json(path)
    return json == nil ? {} : json
end

def lookup_tag(tag)
    return nil if tag == ""
    code_lists = ["40100_0135", "EDSD"]
    title, definition = "", ""
    for code_list in code_lists do
        if $code_lists.key?(code_list) && $code_lists[code_list].key?(tag)
            title = $code_lists[code_list][tag]["title"]
            definition = $code_lists[code_list][tag]["description"]
        end
        return title, definition unless title == ""
    end
    return title, definition
end

def lookup_qualifier(code_list, code, value)
    return nil if value == ""
    reference, description = "", ""
    csv_path = "#{CODE_PATH}/#{code_list}/#{code}.csv"
    unless File.file?(csv_path)
        exists = (
            $code_lists.key?(code_list) &&
            $code_lists[code_list].key?(code) &&
            $code_lists[code_list][code].key?(value)
        )
        if exists
            reference   = $code_lists[code_list][code][value]["title"]
            description = $code_lists[code_list][code][value]["description"]
        end
    else
        line = csv_reference(csv_path, value)
        unless line == []
            reference   = line[1]
            description = line[2]
        end
    end
    return Qualifier.new(code, value, reference, description)
end

def csv_reference(path, value)
    if File.file?(path)
        CSV.foreach(path, 'rb:utf-8') do |line|
            return line if (line[0] == value)
        end
    end
    return []
end

def read_document(path)
    lines = File.readlines(path, :encoding => 'utf-8')
    return lines
    #return lines.join.gsub("\n", "").gsub("\r", "")
end

def read_json(path)
    return nil unless File.file?(path)
    file = File.open(path)
    json = JSON.load(file)
    file.close
    return json
end

def strip_csv_column(path, column)
    lines = File.readlines(path, :encoding => 'utf-8')
    return lines.map! { |line| line.split(",")[column] }
end

class Object
    def is_number?
        # to_f.to_s == to_s || to_i.to_s == to_s
        return Float(self) != nil rescue false
    end

    def blank?
        return true if self == nil
        return true if self == false
        return true if self == ""
        return true if self == " "
        return true if self == []
        return true if self == {}
        return false
    end

    def quote(punc = "\"")
        return self.to_s.encap(punc, punc)
    end
end

class Array
    def tail
        return [] if self.empty?
        return self[1..-1]
    end

    def words
        return self.join(" ")
    end
end

class String
    def titleize(slash = true)
        temp = self.downcase
        # By forward slash
        temp = temp.split(/\//).map { |w| w.weak_titleize }.join("/") if slash
        # By space
        temp = temp.split(/ |\_|\-/).map { |w| w.weak_titleize }.words
        return temp 
    end

    def weak_titleize
        # Don't lowercase letters that are not the first letter of string
        # e.g. abc => Abc, abC => AbC, ABc => ABc, abc def => Abc def
        return self.chars.map.with_index { |l, i| i == 0 ? l.upcase : l }.join
    end

    def first(length = 1)
        return self[0, length]
    end
    
    def key
        return self.gsub(" ", "_").downcase
    end

    def unkey
        return self.gsub("_", " ").titleize
    end

    def lpad(n)
        return self.rjust(n, " ")
    end

    def rpad(n)
        return self.ljust(n, " ")
    end

    def encap(a, b)
        return a + self + b
    end

    def words
        return self.split(" ")
    end

    def flatten
        return self
    end
end
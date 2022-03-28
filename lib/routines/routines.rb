# 0x6a j ┘ 0x74 t ├
# 0x6b k ┐ 0x75 u ┤
# 0x6c l ┌ 0x76 v ┴
# 0x6d m └ 0x77 w ┬
# 0x6e n ┼ 0x78 x │
# 0x71 q ─

$previous_path = nil
$previous_interchange = nil

def load_interchange(path)
    unless path == $previous_path
        interchange = EDIFACT::Interchange.new(path)
        $previous_path, $previous_interchange = path, interchange
    else
        interchange = $previous_interchange
    end
    return interchange
end

def ascii_table(data, widths = Array.new(99) { 16 })
    return data.map { |row|
        row.map.with_index { |cell, index|
            cell.ljust(widths[index], " ")
        }.join
    }.join("\n")
end

def routine_help
    out = [""]
    version = File.readlines(VERSION_PATH).first.chomp
    out << File.readlines(USAGE_PATH).map { |l| l.gsub("VERSION", version) }
    return out
end

def routine_html_debug(path)
    out = []
    interchange = load_interchange(path)
    out << html_debug(interchange)
    return out
end

def routine_bayplan(path)
    out = []
    interchange = load_interchange(path)
    out << ascii_bayplan(interchange)
    return out
end

def routine_html_bayplan(path)
    out = []
    interchange = load_interchange(path)
    out << html_bayplan(interchange)
    return out
end

def routine_morph_xml(path)
    out = []
    interchange = load_interchange(path)
    out << Nokogiri::XML(edi_to_xml(interchange)).to_xml
    return out
end

def routine_html_morph_xml(path)
    out = []
    interchange = load_interchange(path)
    edi = interchange.segments.map { |segment| segment.raw }
        .join("\n")
        .html_sanitize
        .html("span", :cl => "edi-span")
        .html("div", 
            :cl => "column scroller m-0 p-0 is-two-fifths",
            :st => "background-color: #F5F5F5; border-right: 1px solid #E7EBED"
        )
    xml = Nokogiri::XML(edi_to_xml(interchange))
        .to_xml
        .html_sanitize
        .html("span", :cl => "edi-span")
        .html("div", 
            :cl => "column scroller m-0 p-0",
            :st => "background-color: #F5F5F5"
        )
    out << [edi, xml].join.html("div", :cl => "columns m-0 p-0")
    return out
end

def routine_morph_json(path)
    out = []
    return out
end

def routine_html_morph_json(path)
    out = []
    return out
end

def routine_morph_csv(path)
    out = []
    return out
end

def routine_html_morph_csv(path)
    out = []
    return out
end
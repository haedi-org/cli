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
        .html("pre")
        .html("span", :cl => "edi-span m-0 p-0")
        .html("div",
            :cl => "column scroller m-0 p-0 is-two-fifths",
            :st => "background-color: #F5F5F5; border-right: 1px solid #E7EBED"
        )
    xml = Nokogiri::XML(edi_to_xml(interchange))
        .to_xml
        .html_sanitize
        .html("code", :cl => "language-xml m-0 p-0")
        .html("pre m-0 p-0")
        .html("span", :cl => "edi-span m-0 p-0")
        .html("div",
            :cl => "column scroller m-0 p-0",
            :st => "background-color: #F5F5F5"
        )
    out << [edi, xml].join.html("div", :cl => "columns m-0 p-0")
    return out
end

def routine_morph_json(path)
    out = []
    interchange = load_interchange(path)
    out << edi_to_json(interchange)
    return out
end

def routine_html_morph_json(path)
    out = []
    return out
end

def routine_morph_csv(path)
    out = []
    interchange = load_interchange(path)
    out << edi_to_arr(interchange).map { |line| line.join(",") }
    return out
end

def routine_html_morph_csv(path)
    out = []
    return out
end

def routine_checklist(edi_path, json_path)
    out = []
    interchange = load_interchange(edi_path)
    data = JSON.load(File.read(json_path))
    requirements = EDIFACT::Requirements.new(interchange, data)
    out << requirements.debug
    return out
end

def routine_html_checklist(edi_path, json_path)
    interchange = load_interchange(edi_path)
    data = JSON.load(File.read(json_path))
    requirements = EDIFACT::Requirements.new(interchange, data)
    return [
        requirements.results.map { |name, data, status, error|
            v = status == 0
            caption = ["Success", "Warning", "Error"][status]
            tag = ["is-success", "is-warning", "is-danger"][status]
            [
                name.html("span", 
                    :cl => "tag",
                    :st => "min-width: 320px; justify-content: left"
                ),
                caption.html("span", 
                    :cl => "tag #{tag}", 
                    :st => "min-width: 72px"
                ),
                (v ? data : error).html("span", :cl => "tag is-light #{tag}"),
            ].join.html("div", :cl => "tags has-addons m-0")
        }
    ].flatten.join.html("div", :cl => "scroller p-4")
end

# <div class="tags has-addons">
#   <span class="tag">Package</span>
#   <span class="tag is-primary">Bulma</span>
# </div>
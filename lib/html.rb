HTML_LINE_BREAK = "<br>"

class String
    def html_sanitize
        return self.gsub("<", "&lt;").gsub(">", "&gt;")
    end
    
    def html_tag(tag, ti: nil, id: nil, cl: nil, st: nil, 
        colspan: nil, onmouseover: nil, onmouseleave:nil)
        open_tag, arr = "<" + tag, [
            ["id", id&.quote], ["class", cl&.quote], ["style", st&.quote],
            ["title", ti&.quote], ["colspan", colspan&.quote],
            ["onmouseover", onmouseover&.quote("'")],
            ["onmouseleave", onmouseleave&.quote("'")]
        ]
        for arg, var in arr do
            open_tag += " #{arg}=#{var}" unless var.blank?
        end
        return self.encap(open_tag + ">", tag.encap("</", ">"))
    end
end 

def html_interactive_segment(line)
    if line.is_a?(UNA)
        # Tag
        clr, fwt = "#2B2B2B", "normal"
        style = "color: #{clr}; font-weight: #{fwt}"
        a = line.raw[0, 3].html_tag("b", :st => style)
        # Characters
        clr, fwt = "#000000", "normal"
        style = "color: #{clr}; font-weight: #{fwt}"
        b = line.raw[3..-1].html_tag("b", :st => style)
        return a + b
    end
    return line.data.map.with_index { |component, c|
        component.map.with_index { |data, d|
            class_name = "L-#{line.line_no}-#{c}-#{d}"
            clr, fwt = "#2B2B2B", "normal"
            onmouseover = "highlightElement(#{class_name.quote})"
            onmouseleave = "restoreElement(#{class_name.quote}, #{clr.quote})"
            # Return <b> tag with CSS styling
            data.html_tag("b", 
                :cl => "edi-data #{class_name}",
                :st => "color: #{clr}; font-weight: #{fwt}",
                :onmouseover => onmouseover,
                :onmouseleave => onmouseleave
            )
        }.join(line.chars.component_element_seperator)
    }.join(line.chars.data_element_seperator) + line.chars.segment_terminator
end

def html_reference_table(document)
    # Raw data
    html_raw_data = String.new
    for line in document.lines do
        html_raw_data += html_interactive_segment(line)
        html_raw_data += HTML_LINE_BREAK
    end
    html_raw_data = html_raw_data
        .html_tag("span", :cl => "edi-span")
        .html_tag("div", 
            :cl => "column scroller is-two-fifths", 
            :st => "background-color: #F5F5F5"
        )
    # Tabular data
    html_tabular_data = String.new
    for line in document.lines do
        # Header row
        clr, fwt = "#2B2B2B", "normal"
        # Build row data
        class_name = "L-#{line.tag.loc.join("-")}"
        row = String.new
        row += line.tag.value.html_tag("th", :st => "color: inherit")
        row += line.tag.title.html_tag("th", :st => "color: inherit", :colspan => 0)
        row += String.new.html_tag("th", :st => "color: inherit")
        # Build row
        html_tabular_data += row.html_tag("tr",
            :cl => class_name,
            :onmouseover => "highlightElement(#{class_name.quote}, true)",
            :onmouseleave => "restoreElement(#{class_name.quote}, #{clr.quote})"
        )
        # Data rows
        for loc, vals in line.rows do
            code, title, value, data, desc = vals
            # Build tag and abbr
            tag = value.html_tag("span", :cl => "tag is-info is-light")
            abbr = data.html_tag("abbr", :ti => desc)
            # Build row data
            row = String.new
            row += code.html_tag("td")
            row += title.html_tag("td")
            is_diff = (value != data) && (value != "")
            data_dom = desc == "" ? data : abbr
            row += (is_diff ? [data_dom, tag].join(" ") : data).html_tag("td")
            # Build row
            clr, fwt = "#2B2B2B", "normal"
            class_name = "L-#{loc.join("-")}"
            onmouseover = "highlightElement(#{class_name.quote}, true)"
            onmouseleave = "restoreElement(#{class_name.quote}, #{clr.quote})"
            html_tabular_data += row.html_tag("tr", 
                :cl => class_name,
                :onmouseover => onmouseover,
                :onmouseleave => onmouseleave
            )
        end
    end
    html_tabular_data = html_tabular_data
        .html_tag("table", :cl => "table is-striped is-hoverable edi-table")
        .html_tag("div", :cl => "column scroller p-0")
    # Return combined HTML elements
    return [html_raw_data, html_tabular_data].join
        .html_tag("div", :cl => "columns is-gapless")
end

def html_document_information(document)
    out = []
    for key, value in document.info do
        key = key.to_s.unkey.html_tag("td")
        value = value.html_tag("td")
        out << [key, value].join.html_tag("tr")
    end
    return out
        .flatten.join
        .html_tag("table", :cl => "table is-borderless")
        .html_tag("div", :cl => "scroller")
end
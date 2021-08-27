HTML_LINE_BREAK = "<br>"

class String
    def html_sanitize
        return self.gsub("<", "&lt;").gsub(">", "&gt;")
    end
    
    def html(tag, ti: nil, id: nil, cl: nil, st: nil, 
        colspan: nil, onmouseover: nil, onmouseleave:nil)
        arr = [
            ["id", id&.quote], 
            ["class", cl&.quote], 
            ["style", st&.quote],
            ["title", ti&.quote], 
            ["colspan", colspan&.quote],
            ["onmouseover", onmouseover&.quote("'")],
            ["onmouseleave", onmouseleave&.quote("'")],
        ]
        open_tag = "<" + tag
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
        a = line.raw[0, 3].html("b", :st => style)
        # Characters
        clr, fwt = "#000000", "normal"
        style = "color: #{clr}; font-weight: #{fwt}"
        b = line.raw[3..-1].html("b", :st => style)
        return a + b
    end
    return line.data.map.with_index { |component, c|
        component.map.with_index { |data, d|
            class_name = "L-#{line.line_no}-#{c}-#{d}"
            clr, fwt = "#2B2B2B", "normal"
            onmouseover = "highlightElement(#{class_name.quote})"
            onmouseleave = "restoreElement(#{class_name.quote}, #{clr.quote})"
            # Return <b> tag with CSS styling
            data.html("b", 
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
        .html("span", :cl => "edi-span")
        .html("div", 
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
        row += line.tag.value.html("th", :st => "color: inherit")
        row += line.tag.title.html("th", :st => "color: inherit", :colspan => 0)
        row += String.new.html("th", :st => "color: inherit")
        # Build row
        html_tabular_data += row.html("tr",
            :cl => class_name,
            :onmouseover => "highlightElement(#{class_name.quote}, true)",
            :onmouseleave => "restoreElement(#{class_name.quote}, #{clr.quote})"
        )
        # Data rows
        for loc, vals in line.rows do
            code, title, value, data, desc = vals
            # Build tag and abbr
            tag = value.html("span", :cl => "tag is-info is-light")
            abbr = data.html("abbr", :ti => desc)
            # Build row data
            row = String.new
            row += code.html("td")
            row += title.html("td")
            is_diff = (value != data) && (value != "")
            data_dom = desc == "" ? data : abbr
            row += (is_diff ? [data_dom, tag].join(" ") : data).html("td")
            # Build row
            clr, fwt = "#2B2B2B", "normal"
            class_name = "L-#{loc.join("-")}"
            onmouseover = "highlightElement(#{class_name.quote}, true)"
            onmouseleave = "restoreElement(#{class_name.quote}, #{clr.quote})"
            html_tabular_data += row.html("tr", 
                :cl => class_name,
                :onmouseover => onmouseover,
                :onmouseleave => onmouseleave
            )
        end
    end
    html_tabular_data = html_tabular_data
        .html("table", :cl => "table is-striped is-hoverable edi-table")
        .html("div", :cl => "column scroller p-0")
    # Return combined HTML elements
    return [html_raw_data, html_tabular_data].join
        .html("div", :cl => "columns is-gapless")
end

def html_document_information(document)
    out = []
    for tag, data in curate_document_key_info(document) do
        caption = lookup_tag(tag.to_s.upcase).first
        header = (caption == "" ? tag.to_s.upcase : caption)
            .html("h1")
            .html("div", :cl => "message-header")
        body = []
        for key, value in data do
            key = key
                .to_s.unkey
                .html("td", :st => "width: 40%")
            value = value
                .html("b")
                .html("td")
            body << [key, value]
                .flatten.join
                .html("tr")
        end
        body = body
            .flatten.join
            .html("div", :cl => "message_body")
        out << [header, body]
            .flatten.join
            .html("table", :cl => "table is-borderless is-fullwidth")
            .html("article", :cl => "message block is-small is-link")
    end
    return out
        .flatten.join
        .html("div", :cl => "scroller p-4")
end

def html_error(error)
    # Error message
    message_title = [
        "Exception error".html("b"), error.class.to_s.encap("(", "):")
    ].join(" ")
    message = error.message.to_s.html_sanitize
    # Error traceback
    trace_title = [
        "Traceback".html("b"), "(most recent call last):"
    ].join(" ")
    trace = error.backtrace.map.with_index do |e, i| 
        prefix = "#{(error.backtrace.length - i)}: from ".rjust(16, " ")
        prefix + e.html_sanitize
    end
    # Contruct body
    return [message_title, message, trace_title, trace.join("\n")]
        .flatten.join("\n")
        .html("span", :st => "font-size: 0.8em; line-height: 0.8em")
        .html("div", :cl => "notification is-danger is-small block")
        .html("div", :cl => "is-fullwidth scroller p-4")
end
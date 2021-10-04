HTML_LINE_BREAK = "<br>"
NBSP = "&nbsp;"

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

def html_debug(document)
    out = []
    return out
end

def html_interactive_tag(tag, segment)
    is_valid = segment.is_valid?
    clr = is_valid ? "#2B2B2B" : "#F14668"
    fwt = is_valid ? "normal"  : "bold"
    class_name = "L-#{segment.line_no}-0"
    onmouseover = "highlightElement(#{class_name.quote})"
    onmouseleave = "restoreElement(#{class_name.quote}, #{clr.quote})"
    # Return <b> tag with CSS styling
    return tag.value.html("b", 
        :cl => "edi-data #{class_name}",
        :st => "color: #{clr}; font-weight: #{fwt}",
        :onmouseover => onmouseover,
        :onmouseleave => onmouseleave
    )
end

def html_interactive_element(element, segment)
    is_valid = element.is_valid? and segment.is_valid?
    clr = is_valid ? "#2B2B2B" : "#F14668"
    fwt = is_valid ? "normal"  : "bold"
    class_name = "L-#{segment.line_no}-#{element.position.join("-")}"
    onmouseover = "highlightElement(#{class_name.quote})"
    onmouseleave = "restoreElement(#{class_name.quote}, #{clr.quote})"
    # Return <b> tag with CSS styling
    return element.data_value.html("b", 
        :cl => "edi-data #{class_name}",
        :st => "color: #{clr}; font-weight: #{fwt}",
        :onmouseover => onmouseover,
        :onmouseleave => onmouseleave
    )
end

def html_interactive_segment(segment)
    data = ([segment.tag] + segment.truncated_elements).map { |element|
        if element.is_a?(Tag)
            html_interactive_tag(element, segment)
        else
            if element.is_a?(Composite)
                element.truncated_elements.map { |element|
                    html_interactive_element(element, segment)
                }.join(segment.chars.component_element_seperator)
            else
                html_interactive_element(element, segment)
            end
        end
    }.join(segment.chars.data_element_seperator)
    return data + segment.chars.segment_terminator
end

def html_reference_table(document)
    # Raw data
    html_raw_data = String.new
    for segment in document.segments do
        clr = segment.is_valid? ? "#2B2B2B" : "#F14668"
        html_raw_data += html_interactive_segment(segment).html("b",
            :st => "font-weight: normal; color: #{clr}"
        )
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
    for segment in document.segments do
        # next unless (line.is_a?(CTA)) or (line.is_a?(COM))
        # Header row
        clr, fwt = "#2B2B2B", "normal"
        # Build row data
        class_name = "L-#{segment.line_no}-0"
        row = String.new
        row += segment.tag.value.html("th", :st => "color: inherit")
        row += segment.tag.name.html("th", 
            :st => "color: inherit", 
            :colspan => 2
        )
        unless segment.is_valid?
            caption = segment.error.message
            row += caption.html("span", :cl => "tag is-danger").html("th")
        else
            row += String.new.html("th", :st => "color: inherit")
        end
        # Build row
        html_tabular_data += row.html("tr",
            :cl => class_name,
            :onmouseover => "highlightElement(#{class_name.quote}, true)",
            :onmouseleave => "restoreElement(#{class_name.quote}, #{clr.quote})"
        )
        # Data rows
        for element in segment.flatten do
            next if element.blank?
            row = String.new
            row += element.code.html("td")
            row += element.name.html("td")
            unless element.data_name.blank?
                row += element.data_name.upcase.html("td")
            else
                row += element.data_value.html("td")
            end
            # Build row
            valid = segment.is_valid? && element.is_valid?
            clr = valid ? "#2B2B2B" : "#F14668"
            fwt = valid ? "normal" : "bold"
            class_name = "L-#{segment.line_no}-#{element.position.join("-")}"
            onmouseover = "highlightElement(#{class_name.quote}, true)"
            onmouseleave = "restoreElement(#{class_name.quote}, #{clr.quote})"
            html_tabular_data += row.html("tr", 
                :cl => class_name,
                :onmouseover => onmouseover,
                :onmouseleave => onmouseleave
            )
        end
        # Data rows
        #for loc, vals in line.rows do
        #    code, title, value, data, desc, valid = vals
        #    # Build tag and abbr
        #    value_tag, valid_tag = String.new, String.new
        #    # Add value tag if interpreted value is different to raw value
        #    if (value != data) && (value != "")
        #        value_tag = value.html("span", :cl => "tag is-info is-light")
        #    end
        #    # Add invalid tag if value is an incorrect data type
        #    unless valid == true
        #        valid_tag = valid.message.html("span", :cl => "tag is-danger")
        #    end
        #    # Add abbr to data if there is a description to be read
        #    data = desc.blank? ? data : data.html("abbr", :ti => desc)
        #    # Build row data
        #    row = String.new
        #    row += code.html("td")
        #    row += title.html("td")
        #    row += [data, value_tag, valid_tag].join(NBSP).html("td")
        #    # Build row
        #    clr = (line.is_valid? && valid == true) ? "#2B2B2B" : "#F14668"
        #    fwt = (line.is_valid? && valid == true) ? "normal" : "bold"
        #    class_name = "L-#{loc.join("-")}"
        #    onmouseover = "highlightElement(#{class_name.quote}, true)"
        #    onmouseleave = "restoreElement(#{class_name.quote}, #{clr.quote})"
        #    html_tabular_data += row.html("tr", 
        #        :cl => class_name,
        #        :onmouseover => onmouseover,
        #        :onmouseleave => onmouseleave
        #    )
        #end
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
    index = 0
    for tag, data in curate_document_key_info(document) do
        color_tag = (index += 1) % 2 == 0 ? "is-primary" : "is-link"
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
            .html("table", 
                :cl => "table is-borderless is-fullwidth",
                :st => "background-color: inherit; border-radius: inherit"
            )
            .html("article", :cl => "message block is-small #{color_tag}")
    end
    return out
        .flatten.join
        .html("div", :cl => "scroller p-4")
end

def html_timeline(document)
    items = []
    # Start timeline heading
    items << "Start"
        .html("span", :cl => "tag is-medium is-primary")
        .html("header", :cl => "timeline-header")
    # Ordered date/time markers
    for caption, time in curate_document_timeline(document) do
        marker = String.new.html("div", :cl => "timeline-marker")
        content = [time.html("p", :cl => "heading"), caption.html("p")]
            .join.html("div", :cl => "timeline-content")
        items << [marker, content].join.html("div", :cl => "timeline-item")
    end
    # End timeline heading
    items << "End"
        .html("span", :cl => "tag is-medium is-primary")
        .html("header", :cl => "timeline-header")
    return items
        .flatten.join
        .html("div", :cl => "timeline is-centered", :st => "padding: 32px")
        .html("div", :cl => "scroller")
end

def html_error(error)
    # Error message
    message_title = [
        "Exception error".html("b"), error.class.to_s.encap("(", "):")
    ].words
    message = error.message.to_s.html_sanitize
    # Error traceback
    traceback_title = [
        "Traceback".html("b"), "(most recent call last):"
    ].words
    traceback = error.backtrace.map.with_index do |e, i| 
        prefix = "#{(error.backtrace.length - i)}: from ".rjust(16, " ")
        prefix + e.html_sanitize
    end
    # Contruct body
    return [message_title, message, traceback_title, traceback.join("\n")]
        .flatten.join("\n")
        .html("span", :st => "font-size: 0.8em; line-height: 0.8em")
        .html("div", :cl => "notification is-danger is-small block")
        .html("div", :cl => "is-fullwidth scroller p-4")
end
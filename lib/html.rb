HTML_LINE_BREAK = "<br>"
NBSP = "&nbsp;"
TICK_CHARACTER = "✓"

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

def html_table(values, cl = "table")
    return values.map { |row|
        (row.map { |value| value.to_s.html("td") }).join.html("tr")
    }.join.html("table", :cl => cl)
end

def html_debug(document)
    out = []
    document_info = [
        ["Message", document.message_type],
        ["Version", document.version],
    ]
    system_info = [
        ["Dictionary read count", $dictionary.read_count],
    ]
    classes = "table is-bordered is-narrow m-2"
    out << html_table(document_info, classes)
    out << html_table(system_info, classes)
    return out
end

def html_interactive_tag(tag, segment)
    valid = segment.is_valid?
    clr = valid ? "#2B2B2B" : "#F14668"
    fwt = valid ? "normal"  : "bold"
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
    no_error = element.is_valid? and segment.is_valid?
    clr, fwt = "#2B2B2B", "normal"
    clr, fwt = "#48C774", "bold" if element.has_integrity?
    clr, fwt = "#F14668", "bold" unless no_error
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
    # Don't use data element separator or terminator for UNA segment 
    separator  = segment.is?('UNA') ? '' : segment.chars.data_element_separator
    terminator = segment.is?('UNA') ? '' : segment.chars.segment_terminator
    # Map and join elements including tag
    data = ([segment.tag] + segment.truncated_elements).map { |element|
        if element.is_a?(Tag)
            html_interactive_tag(element, segment)
        else
            if element.is_a?(Composite)
                element.truncated_elements.map { |element|
                    html_interactive_element(element, segment)
                }.join(segment.chars.component_element_separator)
            else
                html_interactive_element(element, segment)
            end
        end
    }.join(separator)
    return data + terminator
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
            #:colspan => 3
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
            valid = segment.is_valid? && element.is_valid?
            element.tap do |e|
                row = String.new
                # Element code row
                row += e.code.html("td")
                # Element name row
                row += e.name.html("td")
                # Element data row
                shown_data = e.data_name.blank? ? e.data_value : e.data_name
                # Add data description attr tag if it exists
                unless e.data_desc.blank?
                    shown_data = shown_data.html("abbr", :ti => e.data_desc)
                end
                # Data value tag
                unless e.data_name.blank?
                    value_tag = e.data_value.html("span", 
                        :cl => "tag is-info is-light"
                    )
                else
                    value_tag = nil
                end
                # Error tag
                unless e.is_valid?
                    error_tag = e.error.message.html("span", 
                        :cl => "tag is-danger"
                    )
                else
                    error_tag = nil
                end
                # Integrity tag
                if e.has_integrity?
                    integrity_tag = TICK_CHARACTER.html("span",
                        :cl => "tag is-success"
                    )
                else
                    integrity_tag = nil
                end
                # Add to row
                row << [
                    shown_data, value_tag, error_tag, integrity_tag
                ].compact.join(NBSP).html("td")
            end
            # Add row to tabular data
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
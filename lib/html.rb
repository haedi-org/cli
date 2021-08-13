class String
    def html_sanitize
        return self.gsub("<", "&lt;").gsub(">", "&gt;")
    end
end

def html_interactive_segment(line)
    if line.is_a?(UNA)
        clr, fwt = "#2B2B2B", "normal"
        style = "color: #{clr}; font-weight: #{fwt}"
        a = "<b style='#{style}'>#{line.raw[0, 3]}</b>"
        clr, fwt = "#000000", "normal"
        style = "color: #{clr}; font-weight: #{fwt}"
        b = "<b style='#{style}'>#{line.raw[3..-1]}</b>"
        return a + b
    end
    return line.data.map.with_index { |component, c|
        component.map.with_index { |data, d|
            # Set CSS styling
            clr, fwt = "#2B2B2B", "normal"
            style = "color: #{clr}; font-weight: #{fwt}"
            # Return <b> tag with CSS styling
            class_name = "L-#{line.line_no}-#{c}-#{d}"
            mouseover = "onmouseover='highlightElement(\"#{class_name}\")'"
            mouseleave = "onmouseleave='restoreElement(\"#{class_name}\", \"#{clr}\")'"
            "<b class='edi-data #{class_name}' style='#{style}' #{mouseover} #{mouseleave}>#{data}</b>"
        }.join(line.chars.component_element_seperator)
    }.join(line.chars.data_element_seperator) + line.chars.segment_terminator
end

def html_reference_table(document)
    out = []
    out << "<div class=\"columns is-gapless\">"
    out << "<div class=\"column scroller is-two-fifths\" style=\"background-color: #F5F5F5\">"
    # Raw data
    out << "<span class=\"edi-span\">"
    for line in document.lines do
        out << html_interactive_segment(line)
        out << "<br>"
    end
    out << "</span>"
    # Tabular data
    out << "</div>"
    out << "<div class=\"column scroller p-0\">"
    out << "<table class=\"table is-striped is-hoverable edi-table\">"
    for line in document.lines do
        clr, fwt = "#2B2B2B", "normal"
        class_name = "L-#{line.tag.loc.join("-")}"
        mouseover = "onmouseover='highlightElement(\"#{class_name}\", true)'"
        mouseleave = "onmouseleave='restoreElement(\"#{class_name}\", \"#{clr}\")'"
        out << "<tr class=\"#{class_name}\" #{mouseover} #{mouseleave}>"
        out << "<th style=\"color: inherit\">#{line.tag.value}</th>"
        out << "<th style=\"color: inherit\" colspan=\"0\">#{line.tag.title}</th>"
        out << "<th style=\"color: inherit\"></th>" #{class_name}</th>"
        out << "</tr>"
        for loc, row in line.rows do
            code, title, value, data, desc = row
            clr, fwt = "#2B2B2B", "normal"
            class_name = "L-#{loc.join("-")}"
            mouseover = "onmouseover='highlightElement(\"#{class_name}\", true)'"
            mouseleave = "onmouseleave='restoreElement(\"#{class_name}\", \"#{clr}\")'"
            tag = "<span class=\"tag is-info is-light\">#{value}</span>"
            out << "<tr class=\"#{class_name}\" #{mouseover} #{mouseleave}>"
            out << "<td>#{code}</td>"
            out << "<td>#{title}</td>"
            if desc == ""
                if (value != data) && (value != "")
                    out << "<td>#{data} #{tag}</td>"
                else
                    out << "<td>#{data}</td>"
                end
            else
                if (value != data) && (value != "")
                    out << "<td><abbr title=\"#{desc}\">#{data}</abbr> #{tag}</td>"
                else
                    out << "<td><abbr title=\"#{desc}\">#{data}</abbr></td>"
                end
            end
            out << "</tr>"
        end
    end
    out << "</table>"
    out << "</div>"
    out << "</div>"
    return out
end
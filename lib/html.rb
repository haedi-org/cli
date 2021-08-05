class String
    def html_sanitize
        return self.gsub("<", "&lt;").gsub(">", "&gt;")
    end
end

def html_interactive_segment(line)
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
    print "<div class=\"columns is-gapless\">"
    print "<div class=\"column scroller is-two-fifths\" style=\"background-color: #F5F5F5\">"
    # Raw data
    print "<span class=\"edi-span\">"
    for line in document.lines do
        print html_interactive_segment(line), "<br>"
    end
    print "</span>"
    # Tabular data
    print "</div>"
    print "<div class=\"column scroller p-0\">"
    print "<table class=\"table edi-table\">"
    for line in document.lines do
        class_name = "L-#{line.tag.loc.join("-")}"
        print "<tr class=\"#{class_name}\">"
        print "<th style=\"color: inherit\">#{line.tag.value}</th>"
        print "<th style=\"color: inherit\" colspan=\"0\">#{line.tag.title}</th>"
        print "<th style=\"color: inherit\"></th>" #{class_name}</th>"
        print "</tr>"
        for loc, row in line.rows do
            code, title, value, data, desc = row
            class_name = "L-#{loc.join("-")}"
            tag = "<span class=\"tag is-info is-light\">#{value}</span>"
            print "<tr class=\"#{class_name}\">"
            print "<td>#{code}</td>"
            print "<td>#{title}</td>"
            if desc == ""
                if (value != data) && (value != "")
                    print "<td>#{data} #{tag}</td>"
                else
                    print "<td>#{data}</td>"
                end
            else
                if (value != data) && (value != "")
                    print "<td><abbr title=\"#{desc}\">#{data}</abbr> #{tag}</td>"
                else
                    print "<td><abbr title=\"#{desc}\">#{data}</abbr></td>"
                end
            end
            print "</tr>"
        end
    end
    print "</table>"
    print "</div>"
    print "</div>"
end
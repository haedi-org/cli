class String
    def html_sanitize
        return self.gsub("<", "&lt;").gsub(">", "&gt;")
    end
end

def html_reference_table(document)
    print "<div class=\"columns is-gapless\">"
    print "<div class=\"column scroller\" style=\"background-color: #F5F5F5\">"
    # Raw data
    print "<span class=\"edi-span\">"
    for line in document.lines do
        print line.html, "<br>"
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
def html_reference_table(document)
    puts "<div class=\"columns is-gapless\">"
    puts "<div class=\"column scroller\">"
    #<div class="columns is-gapless wrapper">
    #<div class="column pr-0 py-0" style="max-width: 200px">
    for line in document.lines do
        puts "<p>#{line.raw}</p>"
    end
    puts "</div>"
    puts "<div class=\"column scroller\">"
    for group in document.rows do
        puts "<table>"
        for row in group do
            puts "<tr>"
            for cell in row do
                puts "<td>#{cell}</td>"
            end
            puts "</tr>"
        end
        puts "</table>"
    end
    puts "</div>"
    puts "</div>"
end
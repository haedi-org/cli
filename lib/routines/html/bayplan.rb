DATA_COLORS = [
    "#f44336", "#e81e63", "#9c27b0", "#673ab7", "#3f51b5", "#2196f3", "#03a9f4",
    "#00bcd4", "#009688", "#4caf50", "#8bc34a", "#cddc39", "#ffeb3b", "#ffc107",
    "#ff9800", "#ff5722", "#795548", "#9e9e9e", "#607d8b",
]

def bayplan_array(message)
    bays, rows, tiers = message.stowage_ranges
    map = message.stowage_hash_map
    # ---
    arr_bays = []
    for bay in bays do
        arr_tier = []
        for tier in tiers do
            arr_row = []
            for row in rows do
                key = bay + row + tier
                arr_row << (map.key?(key) ? map[key] : nil)
            end
            arr_tier << arr_row
        end
        arr_bays << arr_tier
    end
    return arr_bays
end

def ascii_bayplan(interchange)
    out = []
    for message in interchange.messages(EDIFACT::BAPLIEMessage) do
        bay_range, row_range, tier_range = message.stowage_ranges
        for tiers in bayplan_array(message) do
            out << "BAY \##{tiers.flatten.compact.first.bay}"
            tier_index = -1
            for row in tiers do
                temp = []
                is_first = true
                for stow in row do
                    if is_first
                        temp << tier_range[tier_index += 1]
                        is_first = false
                    end
                    temp << (stow == nil ? "  " : "##")
                end
                out << temp.join
            end
        end
    end
    return out
end

def html_bayplan(interchange)
    out = []
    col_count = 4
    for message in interchange.messages(EDIFACT::BAPLIEMessage) do
        cols, index = Array.new(col_count) { [] }, -1
        bay_range, row_range, tier_range = message.stowage_ranges
        carrier_list = message.carrier_list
        for tiers in bayplan_array(message) do
            bay_no = "Bay \#" + tiers.flatten.compact.first.bay
            table_width = tier_range.length + 1
            cols[(index += 1) % col_count] << [
                # Bay number
                bay_no
                    .html("td", :cl => "bay-no", :colspan => table_width)
                    .html("tr"),
                # Row axis
                ([String.new] + row_range).map do |row|
                    row.html("td", :cl => "axis pb-1")
                end.join.html("tr"),
                # Container grid
                tiers.map.with_index do |row, tier_index|
                    is_first = true
                    row.map do |stow|
                        unless stow == nil
                            cl = ["container"]
                            cl << "full" if stow.full_empty.upcase == "FULL"
                            cl << "empty" if stow.full_empty.upcase == "EMPTY"
                        else
                            cl = ["no-container"]
                        end
                        unless stow == nil
                            clr_index = carrier_list.find_index(stow.carrier_id)
                            clr = DATA_COLORS[clr_index % DATA_COLORS.length]
                            st = "background-color: #{clr};"
                        else
                            st = "" 
                        end
                        unless is_first
                            String.new
                                .html("td", :cl => cl.join(" "), :st => st)
                        else
                            is_first = false
                            [
                                tier_range[tier_index]
                                    .html("td", :cl => "axis pr-1"),
                                String.new
                                    .html("td", :cl => cl.join(" "), :st => st)
                            ]
                        end
                    end.flatten.join.html("tr")
                end
            ].join.html("table", :cl => "bayplan m-2")
        end
    end
    return cols.map do |col|
        col.join.html("div", :cl => "column is-narrow m-0 p-0")
    end.join.html("div", :cl => "columns scroller m-0 p-0")
end
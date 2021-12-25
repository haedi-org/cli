def ascii_bayplan(interchange)
    out = []
    for message in interchange.messages(EDIFACT::BAPLIEMessage) do
        bays, rows, tiers = message.stowage_ranges
        map = message.stowage_hash_map
        # ---
        for bay in bays do
            print "BAY \##{bay}\n\n   "
            for row in rows do
                print row.ljust(3, " ")
            end
            print("\n")
            for tier in tiers do
                print tier.ljust(3, " ")
                for row in rows do
                    print map.key?(bay + row + tier) ? "## " : "   "
                end
                print "\n"
            end
            print "\n"
        end
    end
    return out
end

def html_bayplan(interchange)
    out = []
    for messages in interchange.messages(EDIFACT::BAPLIEMessage) do
        # ...
    end
    return out
end
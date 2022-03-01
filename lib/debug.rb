def routine_debug(path, interchange = nil)
    out = []
    interchange = load_interchange(path) if interchange == nil
    # Output info routine
    out << routine_info(path, interchange)
    # DESADV debugging
    if interchange.messages.first.type == "DESADV"
        # Print roots and leaves
        roots = interchange.messages.first.stowage_roots.map { |k, v| k }
        leaves = interchange.messages.first.stowage_leaves.map { |k, v| k }
        out << "Roots:\t#{roots}\nLeaves:\t#{leaves}\n\n"
        # Print hierarchy
        hierarchy = interchange.messages.first.stowage_hierarchy
        out << "Hier:\t#{hierarchy}\n\n"
        # Print debug
        out << interchange.messages.first.debug
        out << ""
        #out << interchange.messages.first.consignment.to_json
    end
    # Print processing times
    load_time    = sprintf("%.2f", interchange.load_time    * 1000).to_s + "ms"
    process_time = sprintf("%.2f", interchange.process_time * 1000).to_s + "ms"
    out << "Finished in #{process_time} (files took #{load_time} to load)"
    out << ""
    return out
end

def routine_html_debug(path)
    out = []
    interchange = load_interchange(path)
    out << html_debug(interchange)
    return out
end
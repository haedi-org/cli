def routine_debug(path)
    out = []
    interchange = load_interchange(path)
    # Message specific outputs
    for message in interchange.messages do
        # out << message.to_json if message.type == "DESADV"
    end
    out << ""
    # Association and agency
    for message in interchange.messages do
        out << "Subset = #{message.get_subset().inspect}"
        out << "Assc assigned code = #{message.association_assigned_code}"
        out << "Controlling agency = #{message.controlling_agency}"
    end
    out << ""
    # Dictionary information
    used = $dictionary.code_lists_used
    unless used.length == 0
        out << "3rd-party code lists (#{used.length}):\n- #{used.join("\n- ")}"
        out << ""
    end
    # Errors
    messages = interchange.errors.map { |e, l| "[#{l.join(":")}] #{e.message}" }
    unless messages.length == 0
        out << "Errors (#{messages.length}):\n- #{messages.join("\n- ")}"
            .colorize(:light_red)
        out << ""
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
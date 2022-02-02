def routine_debug(path)
    out = []
    interchange = load_interchange(path)
    # Message specific outputs
    for message in interchange.messages do
        out << message.to_json if message.type == "DESADV"
    end
    # Association and agency
    for message in interchange.messages do
        out << ""
        out << "SMDG? = #{message.is_smdg?}"
        out << "UNICORN? = #{message.is_unicorn?}"
        out << "EDIGAS? = #{message.is_edigas?}"
        out << ""
        out << "Assc assigned code = #{message.association_assigned_code}"
        out << "Controlling agency = #{message.controlling_agency}"
    end
    # Dictionary information
    out << ""
    out << "Third-party code lists: #{$dictionary.code_lists_used.join(" ")}"
    out << ""
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
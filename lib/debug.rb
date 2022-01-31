def routine_debug(path)
    out = []
    interchange = load_interchange(path)
    for message in interchange.messages do
        out << "SMDG? = #{message.is_smdg?}"
        out << "UNICORN? = #{message.is_unicorn?}"
    end
    # Dictionary
    out << "Third-party code lists: #{$dictionary.code_lists_used.join(" ")}"
    # Print processing times
    load_time    = sprintf("%.2f", interchange.load_time    * 1000).to_s + "ms"
    process_time = sprintf("%.2f", interchange.process_time * 1000).to_s + "ms"
    out << "Finished in #{process_time} (files took #{load_time} to load)"
    return out
end
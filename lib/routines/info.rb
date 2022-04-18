def routine_info(path, interchange = nil)
    out = []
    interchange = load_interchange(path) if interchange == nil
    # Message specific outputs
    for message in interchange.messages do
        # out << message.to_json if message.type == "DESADV"
    end
    out << ""
    # File info
    out << "File path = #{path}"
    out << "File size = #{File.size(path).to_filesize}"
    out << ""
    # Message info
    for message in interchange.messages do
        out << [
            "Message type = #{message.type}",
            "Message version = #{message.version}",
            "Subset = #{message.subset == nil ? "none" : message.subset}",
            "Association assigned code = #{message.association_assigned_code}",
            "Controlling agency = #{message.controlling_agency}",
        ]
    end
    out << ""
    # Dictionary information
    used = $dictionary.code_lists_used
    used_count = $dictionary.code_lists_used_count
    read_count = $dictionary.read_count
    out << "Dictionary read count = #{read_count}"
    unless used_count == 0
        out << "3rd-party code lists (#{used_count})\n- #{used.join("\n- ")}"
    end
    out << ""
    # Errors
    errs = interchange.errors.map { |e, l| "[#{l.join(":")}] #{e.message}" }
    unless errs.length == 0
        out << "Errors (#{errs.length})\n- #{errs.first(10).join("\n- ")}"
            .colorize(:red)
        out << ""
    end
    return out
end

def routine_html_info(path)
    out = []
    interchange = load_interchange(path)
    out << html_info(interchange)
    return out
end
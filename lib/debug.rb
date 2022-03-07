def routine_debug(path, interchange = nil)
    out = []
    interchange = load_interchange(path) if interchange == nil
    # Output info routine
    out << routine_info(path, interchange)
    # CONTRL debugging
    if interchange.messages.first.type == "CONTRL"
        # Interchange
        action = interchange.messages.first.interchange_action
        action = action.blank? ? "N/A" : action.readable
        out << "Interchange action = #{action}"
        syntax_error = interchange.messages.first.interchange_syntax_error
        syntax_error = syntax_error.blank? ? "N/A" : syntax_error.value
        out << "Interchange syntax error = #{syntax_error}"
        out << ""
        # Message
        action = interchange.messages.first.message_action
        action = action.blank? ? "N/A" : action.readable
        out << "Message action = #{action}"
        syntax_error = interchange.messages.first.message_syntax_error
        syntax_error = syntax_error.blank? ? "N/A" : syntax_error.value
        out << "Message syntax error = #{syntax_error}"
        out << ""
        # Segment
        seg_pos = interchange.messages.first.segment_position_in_body
        seg_pos = seg_pos.blank? ? "N/A" : seg_pos.value
        out << "Segment position in body = #{seg_pos}"
        syntax_error = interchange.messages.first.segment_syntax_error
        syntax_error = syntax_error.blank? ? "N/A" : syntax_error.value
        out << "Segment syntax error = #{syntax_error}"
        out << ""
        syntax_error = interchange.messages.first.segment_syntax_error
    end
    # APERAK debugging
    if interchange.messages.first.type == "APERAK"
        # Print application error identification
        error_id = interchange.messages.first.application_error_id
        error_id = error_id.blank? ? "N/A" : error_id.readable
        out << "Application error identification = #{error_id}"
        # Print code list qualifier
        code_list = interchange.messages.first.code_list_qualifier
        code_list = code_list.blank? ? "N/A" : code_list.readable
        out << "Code list qualifier = #{code_list}"
        # Print responsible agency
        agency = interchange.messages.first.responsible_agency
        agency = agency.blank? ? "N/A" : agency.readable
        out << "Responsible agency = #{agency}"
        out << ""
    end
    # DESADV debugging
    if interchange.messages.first.type == "DESADV"
        # Print debug
        out << interchange.messages.first.debug
        out << ""
        # Print roots and leaves
        roots = interchange.messages.first.stowage_roots.map { |k, v| k }
        leaves = interchange.messages.first.stowage_leaves.map { |k, v| k }
        out << "Roots = #{roots}\nLeaves = #{leaves}\n\n"
        # Print hierarchy
        hierarchy = interchange.messages.first.stowage_hierarchy
        out << "Hier = #{hierarchy}\n\n"
        # Print test ASCII
        out << interchange.messages.first.ascii
        out << ""
        # Print consignment
       #consignment = interchange.messages.first.consignment
       #out << "Consignment = #{JSON.pretty_generate(consignment)}\n\n"
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
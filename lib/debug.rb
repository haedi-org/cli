def _routine_debug(path, interchange = nil)
    interchange = load_interchange(path) if interchange == nil
    data = JSON.load(File.read('./requirements_example.json'))
    requirements = EDIFACT::Requirements.new(interchange, data)
    return nil
end

def routine_debug(path, interchange = nil)
    out = []
    interchange = load_interchange(path) if interchange == nil
    # Output info routine
    out << routine_info(path, interchange)
    # API URLs
    valid_urls, invalid_urls = $dictionary.valid_urls, $dictionary.invalid_urls
    unless valid_urls.empty?
        out << "Valid API endpoints (#{valid_urls.length})".colorize(:green)
        out << valid_urls.map{ |u| "- #{u}".colorize(:green) }
        out << ""
    end
    unless valid_urls.empty?
        out << "Invalid API endpoints (#{invalid_urls.length})".colorize(:red)
        out << invalid_urls.map{ |u| "- #{u}".colorize(:red) }
        out << ""
    end
    # Get first message
    message = interchange.messages.compact.first
    # CONTRL debugging
    if message&.type == "CONTRL"
        # Interchange
        action = message.interchange_action
        action = action.blank? ? "N/A" : action.readable
        out << "Interchange action = #{action}"
        syntax_error = message.interchange_syntax_error
        syntax_error = syntax_error.blank? ? "N/A" : syntax_error.value
        out << "Interchange syntax error = #{syntax_error}"
        out << ""
        # Message
        action = message.message_action
        action = action.blank? ? "N/A" : action.readable
        out << "Message action = #{action}"
        syntax_error = message.message_syntax_error
        syntax_error = syntax_error.blank? ? "N/A" : syntax_error.value
        out << "Message syntax error = #{syntax_error}"
        out << ""
        # Segment
        seg_pos = message.segment_position_in_body
        seg_pos = seg_pos.blank? ? "N/A" : seg_pos.value
        out << "Segment position in body = #{seg_pos}"
        syntax_error = message.segment_syntax_error
        syntax_error = syntax_error.blank? ? "N/A" : syntax_error.value
        out << "Segment syntax error = #{syntax_error}"
        out << ""
        syntax_error = message.segment_syntax_error
    end
    # APERAK debugging
    if message&.type == "APERAK"
        # Print application error identification
        error_id = message.application_error_id
        error_id = error_id.blank? ? "N/A" : error_id.readable
        out << "Application error identification = #{error_id}"
        # Print code list qualifier
        code_list = message.code_list_qualifier
        code_list = code_list.blank? ? "N/A" : code_list.readable
        out << "Code list qualifier = #{code_list}"
        # Print responsible agency
        agency = message.responsible_agency
        agency = agency.blank? ? "N/A" : agency.readable
        out << "Responsible agency = #{agency}"
        out << ""
    end
    # DESADV debugging
    if message&.type == "DESADV"
        # Print debug
        out << message.debug
        out << ""
        # Print roots and leaves
        roots = message.stowage_roots.map { |k, v| k }
        leaves = message.stowage_leaves.map { |k, v| k }
        out << "Roots = #{roots}\nLeaves = #{leaves}\n\n"
        # Print hierarchy
        hierarchy = message.stowage_hierarchy
        out << "Hier = #{hierarchy}\n\n"
        # Print test ASCII
        out << message.ascii
        out << ""
        # Validate Amazon ASN
        out << interchange.is_amazon_asn?
        # Print consignment
       #consignment = message.consignment
       #out << "Consignment = #{JSON.pretty_generate(consignment)}\n\n"
    end
    # Print processing times
    load_time    = sprintf("%.2f", interchange.load_time    * 1000).to_s + "ms"
    process_time = sprintf("%.2f", interchange.process_time * 1000).to_s + "ms"
    out << "Finished in #{process_time} (files took #{load_time} to load)"
    out << ""
    File.write('test.json', $dictionary.cache.to_json)
    return out
end

def routine_html_debug(path)
    out = []
    interchange = load_interchange(path)
    out << html_debug(interchange)
    return out
end
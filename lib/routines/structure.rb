def routine_structure(path)
    out = []
    interchange = load_interchange(path)
    messages = interchange.messages
    messages.compact.each_with_index do |message, m_i|
        out << "#{message.type} (\##{message.reference})"
        groups = message.groups
        groups.each_with_index do |group, g_i|
            g_branch = (g_i == groups.length - 1 ? " └─ " : " ├─ ")
            out << g_branch + group.name
            segments = group.segments
            segments.each_with_index do |segment, s_i|
                g_branch = (g_i == groups.length - 1 ? "    " : " │  ")
                s_branch = (s_i == segments.length - 1 ? " └─ " : " ├─ ")
                caption = segment.tag.value + ": " + segment.tag.name
                out << g_branch + s_branch + caption
            end
        end
    end
    return out
end
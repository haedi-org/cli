def routine_timeline(path)
    out = []
    interchange = load_interchange(path)
    interchange.messages.each do |message|
        out << "#{message.type} (\##{message.reference})"
        timeline = message.timeline
        timeline.each_with_index do |data, t_i|
            name, date = data
            t_branch = (t_i == timeline.length - 1 ? " └─ " : " ├─ ")
            out << t_branch + name
            t_branch = (t_i == timeline.length - 1 ? "    " : " │  ")
            n_branch = " └─ "
            out << t_branch + n_branch + date
        end
    end
    #for timeline in timelines do
    #    out << ascii_table(timeline, [40, 40]) unless timeline.blank?
    #end
    return out
end

def routine_html_timeline(path)
    out = []
    interchange = load_interchange(path)
    out << html_timeline(interchange)
    return out
end
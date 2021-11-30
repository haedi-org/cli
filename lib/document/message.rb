# Lines given in the form [[line_no, line_data], [line_no, line_data], ...]
# [[2, "UNH+SSDD1+ORDERS:D:03B:UN:EAN008'"], [3, "BGM+220+BKOD99+9'"], ...]

class Message
    attr_reader :version

    def initialize(lines, interchange_version = '4', chars = DEFAULT_CHARS)
        @lines = lines
        @interchange_version = interchange_version
        @chars = chars
        @spec = nil
        @type = nil
        @version = nil
        @header = nil
        @trailer = nil
        @groups = []
        # Initial methods
        set_header()
        set_trailer()
        set_spec()
        set_groups()
        #
        puts @header
        puts @trailer
        #puts @spec
    end

    def set_header()
        for line_no, line_data in @lines do
            if line_data.first(3) == 'UNH'
                params = [line_data, line_no, @interchange_version, @chars]
                @header = SegmentFactory.new(*params).segment
                @type = @header.message_type.data_value
                @version = @header.version_key
            end
        end
    end

    def set_trailer()
        for line_no, line_data in @lines do
            if line_data.first(3) == 'UNT'
                params = [line_data, line_no, @interchange_version, @chars]
                @trailer = SegmentFactory.new(*params).segment
            end
        end
    end

    def set_spec()
        @spec = $dictionary.message_structure_specification(@type, @version)

    end

    def exists_in_group?(str, group_no, order = [])
        order << group_no.to_s
        @spec[group_no.to_s.gsub("SG", "")].tap do |group_data|
            for value in group_data["structure"] do
                if value.length == 4 # e.g. SG20
                    # Recursively call method
                    return exists_in_group?(str, value, order)
                elsif value == str.first(3)
                    # Break out with information
                    return group_data["segments"][value], order
                end
            end
        end
        # Return false if no match is found
        return false, order
    end

    def set_groups()
        group_factory = GroupFactory.new(@lines, @spec)
        for group_no, line in group_factory.raw
            puts "#{group_no}\t#{line.chomp}"
        end
    end

    def _set_groups()
        def next_group(g, s, g_r = 0, s_r = 0)
            return (g + 1), 0
        end
        def next_segment(g, s)
            wrap = @spec[g.to_s]["segments"].length == s + 1
            return (wrap ? g + 1 : g), (wrap ? 0 : s + 1)
        end
        def repeat_group(g, s)
            puts "ATTEMPTING TO REPEAT GROUP"
            return g, 0
        end
        # Need to collapse SG__'s in spec
        result = []
        g_index = 0
        s_index = 0
        line_index = 0
        is_repeating_group = false
        until false
            # Retrieve data by index
            line = @lines[line_index][1]
            next_line = @lines[line_index + 1][1]
            group_data = @spec[g_index.to_s]
            if group_data.blank?
                puts [g_index, s_index, line].inspect
                puts result.inspect
                return false
            end
            segment_tag, segment_data = group_data["segments"].to_a[s_index]
            # Get data points for ease of reading
            if is_repeating_group
                group_repeat_counter -= 1
                if group_repeat_counter == 0
                    puts "NOT ENOUGH GROUP REPEATS"
                    puts [g_index, s_index, line].inspect
                    puts result.inspect
                end
            else
                group_repeat_counter = (group_data["repeat"].to_i)
            end
            segment_repeat_counter = (segment_data["repeat"].to_i)
            group_is_mandatory = is_repeating_group ? false : (group_data["m_c"] == "M")
            group_is_conditional = is_repeating_group ? true : (group_data["m_c"] == "C")
            segment_is_mandatory = is_repeating_group ? false : (segment_data["m_c"] == "M")
            segment_is_conditional = is_repeating_group ? true : (segment_data["m_c"] == "C")
            segment_matches_line = (line.first(3) == segment_tag)
            first_segment_in_group = (s_index == 0)
            last_segment_in_group = (s_index == group_data["segments"].length - 1)
            group_contains_current_line = (group_data["segments"].key?(line.first(3)))
            group_contains_next_line = (group_data["segments"].key?(next_line.first(3)))
            attempt_to_repeat_group = (last_segment_in_group and group_contains_current_line and (group_repeat_counter > 1))
            is_repeating_group = false
            # Check if line is valid
            puts [line, segment_tag, g_index, s_index, group_is_mandatory, segment_is_mandatory, next_line.first(3), last_segment_in_group, group_contains_current_line, attempt_to_repeat_group].inspect
            if segment_matches_line
                puts "SEGMENT MATCHES LINE"
                # Look ahead to add any repeating segments unless first in segment
                unless first_segment_in_group
                    temp_arr = []
                    until line.first(3) != segment_tag
                        temp_arr << [g_index, line]
                        line = @lines[line_index += 1][1]
                    end
                    if temp_arr.length <= segment_repeat_counter
                        result << [temp_arr]
                        if attempt_to_repeat_group
                            g_index, s_index = repeat_group(g_index, s_index)
                        else
                            g_index, s_index = next_segment(g_index, s_index)
                        end
                    else
                        puts "SEGMENT REPEATS OVER #{segment_repeats} TIMES"
                        puts temp_arr
                        puts result.inspect
                        return false
                    end
                else
                    result << [g_index, line]
                    line_index += 1
                    if attempt_to_repeat_group
                        g_index, s_index = repeat_group(g_index, s_index)
                    else
                        g_index, s_index = next_segment(g_index, s_index)
                    end
                end
            else
                if (group_is_mandatory and segment_is_mandatory)
                    puts "GROUP MANDATORY AND SEGMENT MANDATORY"
                    puts [line, segment_tag, g_index, s_index].inspect
                    puts result.inspect
                    return false
                end
                if (group_is_mandatory and segment_is_conditional)
                    if attempt_to_repeat_group
                        g_index, s_index = repeat_group(g_index, s_index)
                    else
                        g_index, s_index = next_segment(g_index, s_index)
                    end
                end
                if (group_is_conditional and segment_is_conditional)
                    if first_segment_in_group
                        g_index, s_index = next_group(g_index, s_index)
                    else
                        if attempt_to_repeat_group
                            g_index, s_index = repeat_group(g_index, s_index)
                        else
                            g_index, s_index = next_segment(g_index, s_index)
                        end
                    end
                end
                if (group_is_conditional and segment_is_mandatory)
                    if first_segment_in_group
                        g_index, s_index = next_group(g_index, s_index)
                    else
                        puts "GROUP CONDITIONAL AND SEGMENT MANDATORY"
                        puts [segment_tag, line].inspect
                        puts result.inspect
                        return false
                    end
                end
            end
        end
    end


    #def set_groups()
    #    result = []
    #    line_index = 0
    #    group_index = 0
    #    break_limit = 999
    #    condition = "M"
    #    repeat = 1
    #    until (line_index >= @lines.length) or (break_limit < 0)
    #        break_limit -= 1
    #        puts ["GROUP_#{group_index}", condition, repeat, group_data["structure"]].inspect
    #        current_line = @lines[line_index][1]
    #        segment_exists, order = exists_in_group?(current_line, group_index)
    #        if segment_exists
    #            result << [group_no, current_line]
    #            repeat -= 0
    #            if repeat == 0
    #                group_index += 1
    #                condition = @spec[group_index]["m_c"]
    #                repeat = @spec[group_index]["repeat"]
    #            else
    #                condition = "C"
    #            end
    #        else
    #            if condition == "C"
    #                group_index += 1
    #                condition = @spec[group_index]["m_c"]
    #                repeat = @spec[group_index]["repeat"]
    #            else
    #                # Mandatory segment not in group
    #                
    #            end
    #        end
    #    end
#
#
    #    for group_no, group_data in @spec do
    #        puts ["GROUP_#{group_no}", group_data["m_c"], group_data["repeat"], group_data["structure"]].inspect
    #        current_tag = @lines[line_index][1].first(3)
    #        puts [current_tag, exists_in_group?(current_tag, group_no)].inspect
#
    #        #for segment_tag, segment_data in group_data["segments"] do
    #        #    puts [segment_tag, segment_data["m_c"], segment_data["repeat"]].inspect
    #        #    current_tag = @lines[line_index][1].first(3)
    #        #    puts [current_tag, exists_in_group?(current_tag, group_no)].inspect
    #        #    puts ""
    #        #end
    #    end
    #    #for line in @lines do
    #    #    puts line[1].first(3).inspect
    #    #end
    #end
end
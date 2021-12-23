module EDIFACT
    class GroupFactory
        attr_reader :groups

        def initialize(lines, spec, message_version, chars)
            @lines = lines
            @spec = spec
            @message_version = message_version
            @chars = chars
            @groups = []
            @raw = []
            @errors = []
            group_structure = Array.new(@spec.length) { |i| "SG#{i}" }
            # Recursively process groups
            line_no, split_no, error = 0, 0, nil
            for group_no in group_structure do
                if error.blank?
                    params = [group_no, line_no, split_no]
                    line_no, split_no, error = process_group(*params)
                    @errors << error unless error.blank?
                end
            end
            # Split groups by split_no
            temp_hash = {}
            for group_no, line, split_no in @raw do
               #puts [group_no, split_no, line].flatten.join("\t")
                unless temp_hash.key?(split_no)
                    temp_hash[split_no] = { 
                        "group_no" => group_no, "lines" => []
                    }
                end
                temp_hash[split_no]["lines"] << line
            end
            # Build groups from hash (name, lines, message_version, chars)
            for split_no, group_data in temp_hash do
                group_no, lines = group_data["group_no"], group_data["lines"]
                name = "GROUP_" + group_no.gsub("SG", "")
                params = [name, lines, message_version, chars]
                @groups << Group.new(*params)
            end
            # Add any trailing lines as individual groups
            n = @lines.length - @raw.length
            for line in @lines[@lines.length - n, n] do
                name = line[1].first(3)
                params = [name, [line], @message_version, @chars]
                @groups << Group.new(*params)
            end
        end

        def process_group(group_no, line_no, split_no = 0, is_first = true, iteration = 1, from_group = nil)
            errors = []
           #puts "\nGroup #{group_no}"
            # Set variables
            group_spec = @spec[group_no.gsub("SG", "")]
            group_is_mandatory = (group_spec["m_c"] == "M") && is_first
            group_repeats = group_spec["repeat"].to_i
            structure = group_spec["structure"]
            # EOF
            return line_no, split_no + 1 if line_no >= @lines.length
            # Assert iteration is under repeat count
            if (iteration > group_repeats)
               #puts "\nToo many iterations (#{iteration} > #{group_repeats})"
               #puts "\nReturning #{group_no}"
                errors << StandardError.new
            end
            # Skip if nested group or repeated group and first mandatory element does not match
            if ((from_group != nil) or (iteration > 1)) and (structure.first != @lines[line_no][1][0, 3])
                return line_no, split_no + 1 if group_spec["segments"][structure.first]["m_c"] == "M"
            end
            # Ensure current line matches start of group if the group is
            # mandatory - and it has not been referenced by another group
            if (group_is_mandatory) && (is_first)
                unless structure.first == @lines[line_no][1][0, 3]
                   #puts "Absent mandatory first segment"
                   errors << StandardError.new
                    
                end
            end
            # Iterate through structure and assign lines as they match
            for tag in structure do
                if tag[0, 3] == @lines[line_no][1][0, 3]
                    segment_spec = group_spec["segments"][tag]
                    segment_repeats = segment_spec["repeat"].to_i
                    segment_iterations = 1
                    until (line_no >= @lines.length) || (tag[0, 3] != @lines[line_no][1][0, 3]) || (segment_iterations > segment_repeats)
                       #puts "  Assigned #{@lines[line_no][0]}:#{@lines[line_no][1]}"
                        @raw << [from_group == nil ? group_no : from_group, @lines[line_no], split_no]
                        # TODO: Match repeating elements
                        line_no += 1
                        segment_iterations += 1
                    end
                    # EOF
                    return line_no, split_no + 1, errors if line_no >= @lines.length
                else
                    if group_spec["segments"].key?(tag)
                        segment_spec = group_spec["segments"][tag]
                        segment_is_mandatory = (segment_spec["m_c"] == "M")
                        if group_is_mandatory && segment_is_mandatory
                           #puts "Absent mandatory segment"
                            errors << StandardError.new
                        end
                    else
                        # Nested segment group
                       #puts "\nNested group #{group_no} => #{tag}"
                        from_group = from_group == nil ? group_no : from_group
                        params = [tag, line_no, split_no, false, 1, from_group]
                        line_no, split_no = process_group(*params)
                        # EOF
                        return line_no, split_no + 1, errors if line_no >= @lines.length
                    end
                end
            end
            # Check if group should be repeated
            if (iteration < group_repeats) && (structure.include?(@lines[line_no][1][0, 3]))
               #puts "\nRepeating #{group_no} #{iteration + 1}"
                params = [group_no, line_no, split_no + 1, false, iteration + 1]
                line_no, split_no = process_group(*params)
                # EOF
                return line_no, split_no + 1 if line_no >= @lines.length
            else
               #puts "\nCan't match #{@lines[line_no][0]}:#{@lines[line_no][1][0, 3]} to #{group_no} #{structure.inspect}"
            end
           #puts "\nReturning #{group_no}"
            return line_no, split_no + 1, errors
        end
    end

    class OldGroupFactory
        attr_reader :groups, :raw

        def initialize(lines, spec, message_version, chars)
            @lines = lines
            @spec = spec
            @message_version = message_version
            @chars = chars
            @groups = []
            @raw = []
            # Algorithm variables
            @group_index, @segment_index = 0, 0
            @line_index, @individual_index = 0, 0
            @is_repeating_group = false
            @group_repeat_counter = 1
            # Initial methods
            collapse_spec()
            begin
                assign_groups()
                set_groups()
            rescue => exception
                puts exception
                puts exception.backtrace
            end
        end

        def collapse_spec()
            for group_no, group_data in @spec do
                for segment_group_id in group_data["structure"] do
                    if segment_group_id.gsub("SG", "").is_numeric?
                        # SG3, SG14, etc.
                        spec = group_spec(segment_group_id.gsub("SG", ""))
                        spec_segments = {}
                        spec["segments"].each.with_index do |s, i|
                            spec_segments[s[0]] = s[1].merge(
                                { "first" => (i == 0) }
                            )
                        end
                        for a, b in spec_segments do
                            @spec[group_no]["segments"][a] = b
                        end
                    end
                end
            end
        end

        def set_groups()
            #for group_no, individual_no, line in @raw do
            #    puts "#{group_no}\t#{individual_no}\t#{line[1]}"
            #end
            # Split by individual number
            group_hash = {}
            File.open("./t.txt", "a") { |file|
                for line in @raw do
                    file.puts line.join(",\t")
                end
            }
            for group_no, individual_no, line in @raw do
                unless group_hash.key?(individual_no)
                    group_hash[individual_no] = {
                        "group" => group_no,
                        "lines" => []
                    }
                end
                group_hash[individual_no]["lines"] << line
            end
            # Create group object
            for individual_no, group_data in group_hash do
                name = "GROUP_#{group_data["group"]}"
                params = [name, group_data["lines"], @message_version, @chars]
                @groups << Group.new(*params)
            end
            # Add any trailing lines as individual groups
            n = @lines.length - @raw.length
            for line in @lines[@lines.length - n, n] do
                name = line[1].first(3)
                params = [name, [line], @message_version, @chars]
                @groups << Group.new(*params)
            end
        end

        def next_line()
            @line_index += 1
        end

        def next_group()
           #puts "NEXT GROUP"
            @individual_index += 1
            @group_index += 1
            @segment_index = 0
            @group_repeat_counter = group_spec()["repeat"].to_i
        end

        def next_segment()
           #puts "NEXT SEGMENT"
            if should_attempt_to_repeat_group() #and set_group_repeats()
                repeat_group()
            else
                wrap = (
                    group_segments().length == @segment_index + 1
                )
                if wrap
                    next_group()
                else
                    @group_index = @group_index
                    @segment_index = @segment_index + 1
                end

            end
        end

        def repeat_group()
           #debug()
           #puts "REPEATING GROUP"
            @individual_index += 1
            @segment_index = 0
            @is_repeating_group = true
            @group_repeat_counter -= 1
            if @group_repeat_counter < 1
               #debug("GROUP REPEAT COUNTER LESS THAN 1")
                return
            end
        end

        def line()
            return "" if @lines[@line_index] == nil
            return @lines[@line_index][1]
        end

        def line_tag()
            return line().first(3)
        end

        def group_spec(index = @group_index)
            return @spec[index.to_s]
        end

        def group_segments()
            if @spec.key?(@group_index.to_s)
                return @spec[@group_index.to_s]["segments"]
            else
               #debug("NO GROUP SPEC KEY FOR #{@group_index.to_s}")
                return
            end
        end

        def segment_tag()
            tag, spec = group_segments().to_a[@segment_index]
            return tag
        end

        def segment_spec()
            tag, spec = group_segments().to_a[@segment_index]
            return spec
        end

        def segment_repeat_counter()
            return segment_spec()["repeat"].to_i
        end

        def group_is_mandatory()
            return (@is_repeating_group ? false : (group_spec()["m_c"] == "M"))
        end

        def group_is_conditional()
            return (@is_repeating_group ? true : (group_spec()["m_c"] == "C"))
        end

        def segment_is_mandatory()
            return (@is_repeating_group ? false : (segment_spec()["m_c"] == "M"))
        end

        def segment_is_conditional()
            return (@is_repeating_group ? true : (segment_spec()["m_c"] == "C"))
        end

        def segment_matches_line()
            return (segment_tag() == line_tag())
        end

        def segment_does_not_match_line()
            return (segment_tag() != line_tag())
        end

        def first_segment_in_group(strict = false)
            if (segment_spec().key?("first") and (strict == false))
                return segment_spec()["first"]
            else
                return (@segment_index == 0)
            end
        end

        def not_first_segment_in_group()
            return (!first_segment_in_group())
        end

        def last_segment_in_group()
            return (@segment_index == (group_spec()["segments"].length - 1))
        end

        def group_contains_current_line()
            return (group_spec()["segments"].key?(line_tag()))
        end

        def next_unique_line()
            offset = 1
            until @line_index + offset >= @lines.length
                if (@lines[@line_index + offset][1].first(3) != line_tag())
                    return @lines[@line_index + offset][1]
                end
                offset += 1
            end
            return line_tag()
        end

        def group_does_not_contain_next_unique_line()
            return (!group_spec()["segments"].key?(next_unique_line().first(3)))
        end

        def should_attempt_to_repeat_group()
            return (
                last_segment_in_group() &&
               #group_does_not_contain_next_unique_line() &&
                group_contains_current_line() &&
                (@group_repeat_counter > 1)
            )
        end

        def group_line_data()
            return [@group_index, @individual_index, @lines[@line_index]]
        end

        def debug(str = "")
            puts [
                @group_index,
                @segment_index,
                segment_tag(),
                @group_repeat_counter,
                line(),
                str,
                last_segment_in_group ? "LAST" : "",
                should_attempt_to_repeat_group() ? "SHOULD REPEAT" : "",
                group_does_not_contain_next_unique_line() ? "NO [#{next_unique_line().first(3)}] IN GROUP" : "",
                #group_spec()["segments"]
            ].inspect
        end

        def segment_is_expected()
            if (group_is_mandatory() and segment_is_mandatory())
               #debug("GROUP MAN AND SEG MAN")
                return true
            end
            if (group_is_conditional() and segment_is_mandatory() and not_first_segment_in_group())
               #debug("GROUP CON AND SEG MAN AND NOT FIRST")
                return true
            end
            return false
        end

        def assign_groups()
            until (@group_index >= (@spec.length - 1))
                if group_spec().blank?
                    debug("GROUP SPEC IS BLANK")
                    return
                end
               #debug()
                if segment_matches_line()
                    if first_segment_in_group()
                        @raw << group_line_data()
                        next_line()
                        next_segment()
                    else
                        # If line matches and is not the first segment;
                        # add all repeating segments (within limit)
                        temp_arr = []
                        until (segment_does_not_match_line() or (temp_arr.length == segment_repeat_counter()))
                            temp_arr << group_line_data()
                            next_line()
                        end
                        # Ensure that the list of segments is within the given
                        # repeat number of the specification
                        if temp_arr.length > segment_repeat_counter()
                           #debug("TOO MANY SEGMENT REPEATS")
                            return
                        end 
                        @raw += temp_arr
                        next_segment()
                    end
                else
                    return if segment_is_expected()
                    if first_segment_in_group(true)
                        unless group_contains_current_line()
                            next_group()
                        else
                            next_segment()
                        end
                    else
                        next_segment()
                    end
                end
            end
        end
    end
end
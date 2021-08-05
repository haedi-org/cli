class Line
    attr_reader :raw, :tag

    def initialize(data, line_no, version, chars)
        @raw = data
        @line_no = line_no
        @version = version
        @chars = chars
        @data = @raw.dup
        @tag = tag
        @elements = []
        # Remove last character if segment terminator
        @data = @data[0..-2] if (@data[-1] == @chars.segment_terminator)
        # Split component data elements within line
        @data = @data.split_with_release(
            @chars.data_element_seperator, @chars.release_character
        )
        # Split data elements within components
        @data.map! do |component| 
            component.split_with_release(
                @chars.component_element_seperator, @chars.release_character
            ) 
        end
    end

    def define(position, element_code, is_coded = false, version = nil)
        # Prepend line number to position
        position = [@line_no] + position
        # Get element value
        data_value = data_at(*position)
        data_value = data_value.join("\n") if data_value.is_a?(Array)
        # Return if value is null
        return nil if NULL_VALUES.include?(data_value)
        # Get element title definition
        element_title = define_element_code(element_code).definition
        # Get coded data from reference if data is coded
        if is_coded
            version = @version.ref if version == nil
            qualifier = qualifier_at(element_code, data_value, version)
        end
        # Assign data qualifier values
        qualifier_exists = defined?(qualifier) && qualifier != nil
        data_description = qualifier_exists ? qualifier.definition : ""
        data_reference   = qualifier_exists ? qualifier.reference : ""
        # Return element data type
        return Element.new(
            position, element_code, element_title,
            data_value, data_description, data_reference, is_coded
        )
    end

    def data_at(line, a, b = nil, code = nil, version = nil)
        return nil unless (length_at() > a) && (b == nil || length_at(a) > b)
        return @data[a] if b == nil
        version = @version.ref if version == nil && code != nil
        return code == nil ? @data[a][b] : ref(code, data_at(a, b, version))
    end

    def length_at(index = nil)
        return index == nil ? @data.length : @data[index].length
    end

    def qualifier_at(code, value, version = @version.ref, list = "UNCL")
        return nil if value == nil
        code_list = list + "_" + version
        return lookup_qualifier(code_list, code, value)
    end

    def tag
        loc = [@line_no, 0, 0]
        title, definition = "", ""
        # Service tags
        title, definition = lookup_tag("40100_0135", data_at(*loc))
        return Tag.new(loc, data_at(*loc), title, definition) unless title == ""
        # Other tags
        title, definition = lookup_tag("EDSD", data_at(*loc))
        return Tag.new(loc, data_at(*loc), title, definition) unless title == ""
        # Return with no reference
        return Tag.new(loc, data_at(*loc), title, definition)
    end

    def push_elements(elements)
        elements.compact.each { |e| @elements << e }
    end

    def debug
        puts "[ #{tag.ref} ] #{@raw}\n\n"
    end

    def rows
        data = []
        for element in @elements do
            element_data = ""
            element_loc = ["na"]
            element_desc = ""
            element_value = ""
            if element.is_a?(Element)
                element_loc = element.loc
                element_desc = element.desc
                element_value = element.value
                use_ref = (element.coded && element.ref != "")
                use_ref ||= DATE_CODES.include?(element.code)
                element_data = use_ref ? element.ref : element.value
            end
            data << [
                element_loc, 
                [
                    element.code, 
                    element.title, 
                    element_value, 
                    element_data, 
                    element_desc
                ]
            ]
        end
        return data
    end

    def html(codes = [], typed = [], mssge = [], warng = [], error = [])
        return @data.map.with_index { |component, c|
            component.map.with_index { |data, d|
                # Set CSS styling
                clr, fwt = "#2B2B2B", "normal"
                #clr, fwt = "#2B2B2B", "bold" if [c, d] == [0, 0]
                #clr, fwt = "#3273DC", "bold" if codes.include?([c, d])
                #clr, fwt = "#00D1B2", "bold" if typed.include?([c, d])
                #clr, fwt = "#D512E2", "bold" if mssge.include?([c, d])
                #clr, fwt = "#FFE08A", "bold" if warng.include?([c, d])
                #clr, fwt = "#F14668", "bold" if error.include?([c, d])
                style = "color: #{clr}; font-weight: #{fwt}"
                # Return <b> tag with CSS styling
                class_name = "L-#{@line_no}-#{c}-#{d}"
                mouseover = "onmouseover='highlightElement(\"#{class_name}\")'"
                mouseleave = "onmouseleave='restoreElement(\"#{class_name}\", \"#{clr}\")'"
                "<b class='edi-data #{class_name}' style='#{style}' #{mouseover} #{mouseleave}>#{data}</b>"
            }.join(@chars.component_element_seperator)
        }.join(@chars.data_element_seperator) + @chars.segment_terminator
    end

    def coded_row(code, title, struct)
        return [code, title, struct.value, struct.ref, struct.desc]
    end

    def header_row(with_def = true)
        if with_def
            return ["", "Segment tag", @tag.value, @tag.title, @tag.definition]
        else
            return ["", "Segment tag", @tag.value, @tag.title]
        end
    end

    def table
        rows = [header_row]
        @elements.each do |e|
            if e.is_a?(Element)
                rows << [
                    e.code, e.title, e.value, e.ref, e.desc
                ]
            elsif e.is_a?(Version)
                rows << [
                    e.code, e.title, e.ref, e.ref, ""
                ]
            end
        end
        return rows
    end
end
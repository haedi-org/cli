def edi_to_arr(document)
    arr = []
    for segment in document.segments do
        unless segment.is_a?(UNASegment)
            seg_arr = [segment.tag.value]
            for element in segment.elements do
                if element.is_a?(Composite)
                    sub_arr = []
                    for sub_element in element.elements do
                        sub_arr << sub_element.data_value
                    end
                    seg_arr << sub_arr
                else
                    seg_arr << element.data_value
                end
            end
            arr << seg_arr
        end
    end
    return arr.inspect
end

def edi_to_xml(document)
    xml = String.new
    for segment in document.segments do
        unless segment.is_a?(EDIFACT::UNASegment)
            seg_xml = String.new
            for element in segment.elements do
                unless element.blank?
                    xml_tag = (
                        segment.tag.value + 
                        element.position.flatten.map.with_index { |n, i| 
                            (i == 0 ? n : n + 1).to_s.rjust(2, '0')
                        }.join
                    )
                    unless element.is_a?(EDIFACT::Composite)
                        data_xml = String.new
                        # Name
                        unless element.name.blank?
                            data_xml += [
                                element.code,
                                element.name
                            ].join(": ").xml_comment
                        else
                            data_xml += element.code.xml_comment
                        end
                        # Data value
                        data_xml += element.data_value
                        # Data name
                        unless element.data_name.blank?
                            data_xml += element.data_name.xml_comment
                        end
                        seg_xml += data_xml.xml(xml_tag)
                    else
                        sub_xml = String.new
                        for e in element.elements do
                            sub_xml_tag = (
                                segment.tag.value + 
                                e.position.flatten.map.with_index { |n, i| 
                                    (i == 0 ? n : n + 1).to_s.rjust(2, '0')
                                }.join
                            )
                            data_xml = String.new
                            # Name
                            unless e.name.blank?
                                data_xml += [
                                    e.code,
                                    e.name
                                ].join(": ").xml_comment
                            else
                                data_xml += e.code.xml_comment
                            end
                            # Data value
                            data_xml += e.data_value
                            # Data name
                            unless e.data_name.blank?
                                data_xml += e.data_name.xml_comment
                            end
                            sub_xml += data_xml.xml(sub_xml_tag)
                        end
                        seg_xml += sub_xml.xml(xml_tag)
                    end
                end
            end
            xml += seg_xml.xml(segment.tag.value)
        end
    end
    return xml.xml("EDIFACT")
end
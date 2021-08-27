def curate_document_key_info(document)
    data = {}
    for line in document.lines do
        # Interchange header segment information
        if line.is_a?(UNB)
            data[:unb] = {} unless data.key?(:unb)
            data[:unb].tap do |d|
                d[:sender_identifier] = line.sender_id.value
                d[:recipient_identifier] = line.recipient_id.value
            end
        end
        # Message header segment information
        if line.is_a?(UNH)
            data[:unh] = {} unless data.key?(:unh)
            data[:unh].tap do |d|
                d[:message_reference] = line.message_reference.value
                d[:message_type] = line.message_type.value
                d[:message_version] = line.message_version.ref
                unless line.controlling_agency.blank?
                    d[:controlling_agency] = line.controlling_agency.value
                end
                unless line.association_code.blank?
                    d[:association_code] = line.association_code.value
                end
            end
        end
        # Date/time/period segment information
        if line.is_a?(DTM) && (!line.qualifier.interpreted.blank?)
            data[:dtm] = {} unless data.key?(:dtm)
            data[:dtm].tap do |d|
                d[line.qualifier.interpreted] = line.date.interpreted
            end
        end
        # Reference segment information
        if line.is_a?(RFF) && (!line.reference.interpreted.blank?)
            data[:rff] = {} unless data.key?(:rff)
            data[:rff].tap do |d|
                d[line.reference.interpreted] = line.reference_number.value
            end
        end
        # Name and address information
        if line.is_a?(NAD) && (!line.party_function.interpreted.blank?)
            data[:nad] = {} unless data.key?(:nad)
            data[:nad].tap do |d|
                d[line.party_function.interpreted] = line.party_id.value
            end
        end
    end
    return data
end

def curate_document_timeline(document)
    data = []
    for line in document.lines do
        # Interchange header segment information
        if line.is_a?(UNB)
            unless (line.preparation_date.interpreted.blank?)
                data << [
                    line.preparation_date.definition,
                    line.preparation_date.interpreted
                ]
            end
            unless (line.preparation_time.interpreted.blank?)
                data << [
                    line.preparation_time.definition,
                    line.preparation_time.interpreted
                ]
            end
        end
        # Date/time/period segment information
        if line.is_a?(DTM) && (!line.qualifier.interpreted.blank?)
            data << [
                line.qualifier.interpreted,
                line.date.interpreted
            ]
        end
    end
    # Sort date/times in ascending order
    data.sort! { |a, b| Time.parse(a.last) <=> Time.parse(a.last) }
    # Return date
    return data
end
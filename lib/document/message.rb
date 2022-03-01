# Lines given in the form [[line_no, line_data], [line_no, line_data], ...]
# [[2, "UNH+SSDD1+ORDERS:D:03B:UN:EAN008'"], [3, "BGM+220+BKOD99+9'"], ...]

module EDIFACT
    class Message
        attr_reader :version, :groups, :type, :reference, :subset
        attr_reader :association_assigned_code, :application_reference
        attr_reader :controlling_agency
        attr_reader :header, :trailer

        def initialize(
            lines, interchange_version = '4', chars = DEFAULT_CHARS, 
            application_reference = nil)
            @lines = lines
            @interchange_version = interchange_version
            @chars = chars
            @application_reference = application_reference
            @spec = nil
            @type = nil
            @version = nil
            @header = nil
            @trailer = nil
            @groups = []
            @errors = []
            # Initial methods
            set_header()
            @subset = get_subset()
            set_trailer()
            set_spec()
            set_groups()
            # Apply association code list and integrity validation
            apply_association_code_list()
            apply_association_validation()
        end
        
        def get_subset()
            return case
                when self.is_unicorn?; "UNICORN"
                when self.is_edifice?; "EDIFICE"
                when self.is_eancom?; "EANCOM"
                when self.is_iata?; "IATA"
                else; nil
            end
        end

        def name
            # TODO: return name of message type
            # e.g. DESADV => Despatch advice
        end

        def is_valid?
            return errors().empty?
        end

        def errors
            group_errors = []
            for group in @groups do
                unless group.is_valid?
                    group_errors += group.errors
                end
            end
            return (@errors + group_errors).compact.map do |error, position|
                [error, ([@type] + position)]
            end
        end

        def apply_association_code_list()
            for group in @groups do
                for segment in group.segments do
                    begin
                        if self.is_eancom?
                            segment.apply_association_code_list("9")
                        end
                        if self.is_smdg?
                            segment.apply_association_code_list("306")
                        end
                        if self.is_unicorn?
                            segment.apply_association_code_list("UNICORN")
                        end
                        if self.is_edigas?
                            segment.apply_association_code_list("ZEW")
                        end
                        if self.is_iata?
                            segment.apply_association_code_list("IATA")
                        end
                    rescue
                        # => Association method not defined
                    end
                end
            end
        end

        def apply_association_validation()
            for group in @groups do
                for segment in group.segments do
                    begin
                        if self.is_eancom?
                            segment.apply_association_validation("9")
                        end
                        if self.is_smdg?
                            segment.apply_association_validation("306")
                        end
                        if self.is_unicorn?
                            segment.apply_association_validation("UNICORN")
                        end
                        if self.is_edigas?
                            segment.apply_association_validation("ZEW")
                        end
                    rescue
                        # => Association method not defined
                    end
                end
            end
        end

        def set_header()
            for line_no, line_data in @lines do
                if line_data.first(3) == 'UNH'
                    params = [
                        line_data, line_no, @interchange_version, 
                        @chars, @subset
                    ]
                    @header = SegmentFactory.new(*params).segment
                    @reference = @header.message_reference.data_value
                    @type = @header.message_type.data_value
                    @version = @header.version_key
                    if @header.association_assigned_code.blank?
                        @association_assigned_code = nil
                    else
                        @association_assigned_code = (
                            @header.association_assigned_code.data_value
                        )
                    end
                    if @header.controlling_agency.blank?
                        @controlling_agency = nil
                    else
                        @controlling_agency = (
                            @header.controlling_agency.data_value
                        )
                    end
                end
            end
        end

        def set_trailer()
            for line_no, line_data in @lines do
                if line_data.first(3) == 'UNT'
                    params = [
                        line_data, line_no, @interchange_version, 
                        @chars, get_subset()
                    ]
                    @trailer = SegmentFactory.new(*params).segment
                end
            end
        end

        def set_spec()
            params = [@type, @version, @subset]
            @spec = $dictionary.message_structure_specification(*params)
        end

        def set_groups()
            begin
                params = [@lines, @spec, @version, @chars, get_subset()]
                group_factory = GroupFactory.new(*params)
            rescue
                params = [@lines, nil, @version, @chars, get_subset()]
                group_factory = GroupFactory.new(*params)
                if @spec.blank?
                    @errors << [NoSpecificationError.new, []]
                else
                    @errors << [GroupMatchError.new, []]
                end
            end
            @groups = group_factory.groups
        end

        def timeline()
            events = []
            for group in @groups do
                for segment in group.segments do
                    if segment.tag.value == "UNB"
                        events << [
                            UNB_DATE_TIME_QUALIFIER, [
                                segment.date.readable,
                                segment.time.readable
                            ].join(' ')
                        ]
                    end
                    if segment.tag.value == "DTM"
                        events << [
                            segment.date_time_qualifier.readable, 
                            segment.date_time.readable
                        ]
                    end
                    if segment.tag.value == "MCR" # UNICORN
                        events << [
                            segment.date.name,[
                                segment.date.readable,
                                segment.time.readable
                            ].join(' ') 
                        ]
                    end
                    if segment.tag.value == "RDQ" # UNICORN
                        events << [
                            segment.date.name,[
                                segment.date.readable,
                                segment.time.readable
                            ].join(' ')
                        ]
                    end
                end
            end
            events.sort! do |a, b| 
                Time.parse(a[1]) <=> Time.parse(b[1])
            end
            return events
        end
    end
end
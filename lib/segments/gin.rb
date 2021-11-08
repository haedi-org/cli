class GINSegment < Segment
    attr_reader :date_time_qualifier, :date_time

    def initialize(raw, line_no, version = nil, chars = nil)
        super(raw, line_no, version, chars)
        @identity_number_qualifier = get_elements_by_code("7405").first
        @identity_numbers = get_elements_by_code("7402")
        unless @identity_number_qualifier.blank? or @identity_numbers.blank?
            validate_identity_numbers(
                @identity_number_qualifier.value,
                @identity_numbers
            )
        end
    end

    def validate_identity_numbers(qualifier, number_elements)
        for element in number_elements do
            validity = case qualifier
            when 'AW' # GS1 serial shipping container code
                element.value.is_sscc? ? true : InvalidSSCCError.new
            when 'BJ' # GS1 serial shipping container code
                element.value.is_sscc? ? true : InvalidSSCCError.new
            when 'VV' # Vehicle identity number
                element.value.is_vin? ? true : InvalidVINError.new
            else
                true
            end
            element.add_error(validity) unless validity == true
        end
    end
end

#010   7405  Identity number qualifier          M  1  an..3 	
#020   C208  IDENTITY NUMBER RANGE              M  1
#      7402  Identity number                    M     an..35
#      7402  Identity number                    C     an..35
#030   C208  IDENTITY NUMBER RANGE              M  1
#      7402  Identity number                    M     an..35
#      7402  Identity number                    C     an..35
#040   C208  IDENTITY NUMBER RANGE              M  1
#      7402  Identity number                    M     an..35
#      7402  Identity number                    C     an..35	
#050   C208  IDENTITY NUMBER RANGE              M  1
#      7402  Identity number                    M     an..35
#      7402  Identity number                    C     an..35
#060   C208  IDENTITY NUMBER RANGE              M  1
#      7402  Identity number                    M     an..35
#      7402  Identity number                    C     an..35	
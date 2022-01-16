module EDIFACT
    class Message
        def is_eancom?
            return @association_assigned_code[0, 3] == "EAN"
        end
    
        def is_iata?
            return @controlling_agency == "IA"
        end

        def is_edigas?
            return @controlling_agency == "EG"
        end

        def is_fhsa?
            return @controlling_agency == "FH"
        end

        def is_smdg?
            return @association_assigned_code[0, 4] == "SMDG"
        end
    end
end
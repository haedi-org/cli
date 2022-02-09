module EDIFACT
    class Message
        def is_eancom?
            return false if @association_assigned_code.blank?
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
            return false if @association_assigned_code.blank?
            return @association_assigned_code[0, 4] == "SMDG"
        end
        
        def is_edifice?
            return false if @association_assigned_code.blank?
            return @association_assigned_code[0, 2] == "ED"
        end

        def is_unicorn?
            return true if @controlling_agency == "TTI"
            unless @application_reference.blank?
                return true if @application_reference.include?("UNICORN")
            end
            return false
        end
    end
end
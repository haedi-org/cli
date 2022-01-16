class NoDocumentError < StandardError
    def message
        return "Missing document"
    end
end

class NoElementError < StandardError
    def message
        return "Missing element"
    end
end

class NoSpecificationError < StandardError
    def message
        return "Missing specification"
    end
end

class InvalidReprError < StandardError
    def message
        return "Invalid repr"
    end
end

class InvalidLengthError < StandardError
    def initialize(desc)
        super()
        @desc = desc
    end
    
    def message
        return "Invalid length" if @desc.blank?
        return "Invalid length (expected #{@desc})"
    end
end

class InvalidSymbolsError < StandardError
    def initialize(desc)
        super()
        @desc = desc
    end
    
    def message
        return "Invalid symbols" if @desc.blank?
        return "Must be #{@desc}"
    end
end

class InvalidDocumentError < StandardError
    def message
        return "EDI document is incorrectly formatted"
    end
end

class InvalidSSCCError < StandardError
    def message
        return "Bad SSCC"
    end
end

class InvalidVINError < StandardError
    def message
        return "Bad VIN"
    end
end

class InvalidACRNError < StandardError
    def message
        return "Bad ACRN"
    end
end

class InvalidISBNError < StandardError
    def message
        return "Bad ISBN"
    end
end

class InvalidISSNError < StandardError
    def message
        return "Bad ISSN"
    end
end

class InvalidGTINError < StandardError
    def message
        return "Bad GTIN"
    end
end

class InvalidISO6346ContainerCode < StandardError
    def message
        return "Bad ISO 6346 Container Code"
    end
end

class MandatoryFieldError < StandardError
    def message
        return "Missing mandatory field"
    end
end

class FieldLengthError < StandardError
    def message
        return "Invalid field length"
    end
end

class FieldRepresentationError < StandardError
    def message
        return "Invalid field representation"
    end
end

class InterchangeHeaderDuplicateError < StandardError
    def message
        return "Duplicate interchange header segment"
    end
end

class InterchangeTrailerDuplicateError < StandardError
    def message
        return "Duplicate interchange trailer segment"
    end
end
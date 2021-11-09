class NoDocumentError < StandardError
    def message
        return "No document error"
    end
end

class NoElementError < StandardError
    def message
        return "No element error"
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
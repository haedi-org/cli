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
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
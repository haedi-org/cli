class InvalidDocumentError < StandardError
    def message
        return "EDI document is incorrectly formatted"
    end
end
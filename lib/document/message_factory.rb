module EDIFACT
    class MessageFactory
        attr_reader :message

        def initialize(
            lines, interchange_version = '4', chars = DEFAULT_CHARS, 
            application_reference = nil)
            @message = nil
            for line_no, line_data in lines do
                if line_data.first(3) == 'UNH'
                    params = [line_data, line_no, interchange_version, chars]
                    header = SegmentFactory.new(*params).segment
                    type = header.message_type.data_value
                    params = [
                        lines, 
                        interchange_version, 
                        chars, 
                        application_reference
                    ]
                    begin
                        if MESSAGE_MAP.include?(type)
                            @message = MESSAGE_MAP[type].new(*params)
                        else
                            @message = Message.new(*params)
                        end
                    rescue => exception
                        puts exception
                        puts exception.backtrace
                    end
                end
            end
        end
    end
end
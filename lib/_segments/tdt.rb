class TDT < Line
    def initialize(data, line_no, version, chars)
        super(data, line_no, version, chars)
        # Push to elements
        push_elements([
            # (8051) Transport stage qualifier
            @transport_stage = define([1, 0], "8051", true),
            # (8028) Conveyance reference number
            @conveyance_reference = define([2, 0], "8028"),
            # (8067) Mode of transport, coded
            @mode_of_transport_qualifier = define([3, 0], "8067"),
            # (8066) Mode of transport
            @mode_of_transport = define([3, 1], "8066"),
            # (8179) Type of means of transport identification
            @transportation_means_id = define([4, 0], "8179", true),
            # (8178) Type of means of transport
            @transportation_means = define([4, 1], "8178"),
            # (3127) Carrier identification
            @carrier_id = define([5, 0], "3127"),
            # (1131) Code list qualifier
            @carrier_code_list = define([5, 1], "1131", true),
            # (3055) Code list responsible agency, coded
            @carrier_agency = define([5, 2], "3055", true),
            # (3128) Carrier name
            @carrier_name = define([5, 3], "3128"),
            # (8101) Transit direction, coded
            @transit_direction = define([6, 0], "8101", true),
            # (8457) Excess transportation reason, coded
            @excess_reason = define([7, 0], "8457", true),
            # (8459) Excess transportation responsibility, coded
            @excess_responsibility = define([7, 1], "8459", true),
            # (7130) Customer authorization number
            @customer_authorization = define([7, 2], "7130"),
            # (8213) Id. of means of transport identification
            @id_of_transport_means_id = define([8, 0], "8213"),
            # (1131) Code list qualifier
            @transport_id_code_list = define([8, 1], "1131", true),
            # (3055) Code list responsible agency, coded
            @transport_id_agency = define([8, 2], "3055", true),
            # (8212) Id. of the means of transport
            @transport_means_id = define([8, 3], "8212"),
            # (8453) Nationality of means of transport, coded
            @transport_means_nationality = define([8, 4], "8453"),
            # (8281) Transport ownership, coded
            @transport_ownership = define([9, 0], "8281", true)
        ])
    end
end
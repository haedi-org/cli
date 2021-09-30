class INV < Line
    def initialize(data, line_no, version, chars)
        super(data, line_no, version, chars)
        # Push to elements
        push_elements([
            # (4501) Inventory movement direction, coded
            @movement_direction = define([1, 0], "4501", true),
            # (7491) Type of inventory affected, coded
            @inventory_type = define([2, 0], "7491", true),
            # (4499) Reason for inventory movement, coded
            @movement_reason = define([3, 0], "4499", true),
            # (4503) Inventory balance method, coded
            @balance_method = define([4, 0], "4503", true),
            # (4403) Instruction qualifier
            @instruction_qualifier = define([5, 0], "4403", true),
            # (4401) Instruction, coded
            @instruction_coded = define([5, 1], "4401", true),
            # (1131) Code list qualifier
            @code_list = define([5, 2], "1131", true),
            # (3055) Code list responsible agency, coded
            @agency = define([5, 3], "3055", true),
            # (4400) Instruction
            @instruction = define([5, 4], "4400"),
        ])
    end
end
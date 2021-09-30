class TAX < Line
    def initialize(data, line_no, version, chars)
        super(data, line_no, version, chars)
        # Push to elements
        push_elements([
            # (5283) Duty/tax/fee function qualifier
            @tax_function = define([1, 0], "5283", true),
            # (5153) Duty/tax/fee type, coded
            @tax_type = define([2, 0], "5153", true),
            # (1131) Code list qualifier
            # (3055) Code list responsible agency, coded
            # (5152) Duty/tax/fee type
            # (C533) DUTY/TAX/FEE ACCOUNT DETAIL
            # (5289) Duty/tax/fee account identification
            # (1131) Code list qualifier
            # (3055) Code list responsible agency, coded
            # (5286) Duty/tax/fee assessment basis
            # (C243) DUTY/TAX/FEE DETAIL
            # (5279) Duty/tax/fee rate identification
            # (1131) Code list qualifier
            # (3055) Code list responsible agency, coded
            # (5278) Duty/tax/fee rate 
            # (5273) Duty/tax/fee rate basis identification
            # (1131) Code list qualifier
            # (3055) Code list responsible agency, coded
            # (5305) Duty/tax/fee category, coded
            # (3446) Party tax identification number
        ])
    end
end
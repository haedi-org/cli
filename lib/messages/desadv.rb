module EDIFACT
    class DESADVMessage < Message
        def initialize(lines, interchange_version = '4', chars = DEFAULT_CHARS)
            super(lines, interchange_version, chars)
            @consignment = {}
        end

        def to_json
            return consignment().to_json
        end

        def stowage_list
            @consignment = build_consignment if @consignment.blank?
            return @consignment
        end

        def build_consignment
            cons_id = nil
            for group in @groups do
                # CPS - Consignment packing sequence
                cps = group.get_segments_by_tag("CPS").first
                unless cps.blank?
                    cons_id = cps.hierarchical_id_number.value
                    parent_id = cps.hierarchical_parent_id.value
                    @consignment[cons_id] = {
                        "children" => [],
                        "item_numbers" => {},
                        "lines" => {}
                    }
                    unless parent_id.blank?
                        @consignment[parent_id]["children"] << cons_id
                    end
                end
                # PAC - Package
                pac = group.get_segments_by_tag("PAC").first
                unless pac.blank? or cons_id.blank?
                    @consignment[cons_id]["no_of_packages"] = (
                        pac.number_of_packages.value
                    )
                end
                # LIN - Line
                lin = group.get_segments_by_tag("LIN").first
                unless lin.blank? or cons_id.blank?
                    line_no = lin.line_item_number.readable
                    item_no = lin.item_number.readable
                    item_no_type = lin.item_number_type.readable
                    # TODO: Warn user if line is already in use
                    @consignment[cons_id]["lines"][line_no] = {
                        "item_number" => item_no,
                        "item_number_type" => item_no_type
                    }
                end
                # PCI - Package identification
                pci = group.get_segments_by_tag("PCI").first
                unless pci.blank? or cons_id.blank?
                    @consignment[cons_id]["marking"] = {
                        "instructions" => pci.marking_instructions.readable,
                        "marks" => pci.shipping_marks.map { |mark|
                            mark.readable.blank? ? nil : mark.readable
                        }.compact
                    }
                end
                # MEA - Measure
                mea = group.get_segments_by_tag("MEA").first
                unless mea.blank? or cons_id.blank?
                    @consignment[cons_id]["measure"] = {
                        "purpose" => mea.measurement_purpose.readable,
                        "property" => mea.property_measured.readable,
                        "unit" => mea.measure_unit_qualifier.readable,
                        "value" => mea.measurement_value.readable
                    }
                end
                # GIN - Goods identity number
                gin = group.get_segments_by_tag("GIN").first
                unless gin.blank? or cons_id.blank?
                    @consignment[cons_id]["goods_identity_no"] = {
                        "type" => gin.identity_number_qualifier.readable,
                        "numbers" => gin.identity_numbers.map { |number|
                            number.readable.blank? ? nil : number.readable
                        }.compact
                    }
                end
                # PIA - Item number
                for pia in group.get_segments_by_tag("PIA") do
                    unless pia.blank? or cons_id.blank?
                        for type, number in pia.item_numbers_with_type do
                            type, number = type.readable, number.value
                            unless type.blank? or number.blank?
                                @consignment[cons_id]["item_numbers"][type] = (
                                    number
                                )
                            end
                        end
                    end
                end
                # ALI - Additional information
                ali = group.get_segments_by_tag("ALI").first
                unless ali.blank? or cons_id.blank?
                    origin = ali.country_of_origin.readable
                    unless origin.blank?
                        @consignment[cons_id]["country_of_origin"] = origin
                    end
                    duty_regime = ali.type_of_duty_regime.readable
                    unless duty_regime.blank?
                        @consignment[cons_id]["duty_regime"] = duty_regime
                    end
                    special = ali.special_conditions.map { |condition|
                        condition.readable.blank? ? nil : condition.readable
                    }.compact
                    unless special.blank?
                        @consignment[cons_id]["special_conditions"] = special
                    end
                end
                # IMD - Item description
                imd = group.get_segments_by_tag("IMD").first
                unless imd.blank? or cons_id.blank?
                    @consignment[cons_id]["item_description"] = {
                        "desc_type" => imd.item_description_type.readable,
                        "characteristic" => imd.item_characteristic.readable,
                        "desc_id" => imd.item_description_id.readable,
                        "desc" => imd.readable_description
                    }
                end
                # QTY - Quantity
                qty = group.get_segments_by_tag("QTY").first
                unless qty.blank? or cons_id.blank?
                    @consignment[cons_id]["quantity"] = {
                        "qualifier" => qty.quantity_qualifier.readable,
                        "quantity" => qty.quantity.readable,
                        "unit" => qty.measure_unit_qualifier.readable
                    }
                end
            end
        end

        def debug
            out = []
            for group in @groups do
                out << group.name
               #out << group.raw
                out << ""
                # CPS
                cps = group.get_segments_by_tag("CPS").first
                unless cps.blank?
                    out << "Consignment packing sequence"
                    out << "ID = #{cps.hierarchical_id_number.readable}"
                    out << "Parent ID = #{cps.hierarchical_parent_id.readable}"
                    out << "Packaging level = #{cps.packaging_level.readable}"
                    out << ""
                end
                # PAC
                pac = group.get_segments_by_tag("PAC").first
                unless pac.blank?
                    out << "Package"
                    out << "Number = #{pac.number_of_packages.readable}"
                    out << "Packaging level = #{pac.packaging_level.readable}"
                    out << "Type = #{pac.type_of_packages_id.readable}"
                    out << ""
                end
                # LIN
                lin = group.get_segments_by_tag("LIN").first
                unless lin.blank?
                    out << "Line item"
                    out << "Line number = #{lin.line_item_number.readable}"
                    out << "Item number = #{lin.item_number.readable}"
                    out << "Valid? = #{lin.item_number.has_integrity?}"
                    out << "Item number type = #{lin.item_number_type.readable}"
                    out << ""
                end
                # PCI
                pci = group.get_segments_by_tag("PCI").first
                unless pci.blank?
                    out << "Package identification"
                    out << "Instructions = #{pci.marking_instructions.readable}"
                    out << "Marks = #{pci.shipping_marks.first.readable}"
                    out << ""
                end
                # MEA
                mea = group.get_segments_by_tag("MEA").first
                unless mea.blank?
                    out << "Measure"
                    out << "Purpose = #{mea.measurement_purpose.readable}"
                    out << "Property = #{mea.property_measured.readable}"
                    out << "Unit = #{mea.measure_unit_qualifier.readable}"
                    out << "Value = #{mea.measurement_value.readable}"
                    out << ""
                end
                # GIN
                gin = group.get_segments_by_tag("GIN").first
                unless gin.blank?
                    out << "Goods identity number"
                    out << "Type = #{gin.identity_number_qualifier.readable}"
                    for number in gin.identity_numbers do
                        unless number.readable.blank?
                            out << "Identity number = #{number.readable}"
                        end
                    end
                    out << ""
                end
                # PIA
                for pia in group.get_segments_by_tag("PIA") do
                    unless pia.blank?
                        out << "Item number"
                        out << "Function = #{pia.product_id_function.readable}"
                        for number in pia.item_numbers do
                            unless number.readable.blank?
                                out << "Item number = #{number.readable}"
                            end
                        end
                        for type in pia.item_number_types do
                            unless type.readable.blank?
                                out << "Item type = #{type.readable}"
                            end
                        end
                    end
                    out << ""
                end
                # ALI
                ali = group.get_segments_by_tag("ALI").first
                unless ali.blank?
                    out << "Additional information"
                    out << "Country = #{ali.country_of_origin.readable}"
                    out << "Duty regime = #{ali.type_of_duty_regime.readable}"
                    for special_condition in ali.special_conditions do
                        unless special_condition.blank?
                            out << "Condition = #{special_condition.readable}"
                        end
                    end
                    out << ""
                end
                # IMD
                imd = group.get_segments_by_tag("IMD").first
                unless imd.blank?
                    out << "Item description"
                    out << "Type = #{imd.item_description_type.readable}"
                    out << "Char. = #{imd.item_characteristic.readable}"
                    out << "Desc. ID = #{imd.item_description_id.readable}"
                    out << "Description = #{imd.readable_description}"
                    out << ""
                end
                # QTY
                qty = group.get_segments_by_tag("QTY").first
                unless qty.blank?
                    out << "Quantity"
                    out << "Qualifier = #{qty.quantity_qualifier.readable}"
                    out << "Quantity = #{qty.quantity.readable}"
                    out << "Unit = #{qty.measure_unit_qualifier.readable}"
                    out << ""
                end
            end
            return out
        end
    end
end
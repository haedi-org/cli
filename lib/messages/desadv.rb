module EDIFACT
    class DESADVMessage < Message
        def initialize(lines, interchange_version = '4', chars = DEFAULT_CHARS)
            super(lines, interchange_version, chars)
        end

        def debug
            out = []
            for group in @groups do
                out << group.name
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
                end
                # PIA
                for pia in group.get_segments_by_tag("PIA") do
                    unless pia.blank?
                        out << "Item number"
                        for number in pia.item_numbers do
                            unless number.readable.blank?
                                out << "Item number = #{number.readable}"
                            end
                        end
                    end
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
                end
                # IMD
                imd = group.get_segments_by_tag("IMD").first
                unless imd.blank?
                    out << "Item description"
                    out << "Type = #{imd.item_description_type.readable}"
                    out << "Char. = #{imd.item_characteristic.readable}"
                    out << "Desc. ID = #{imd.item_description_id.readable}"
                    out << "Description = #{imd.readable_description}"
                end
                # QTY
                qty = group.get_segments_by_tag("QTY").first
                unless qty.blank?
                    out << "Quantity"
                    out << "Qualifier = #{qty.quantity_qualifier.readable}"
                    out << "Quantity = #{qty.quantity.readable}"
                    out << "Unit = #{qty.measure_unit_qualifier.readable}"
                end
                out << group.raw
                out << ""
               #lin = group.get_segments_by_tag("LIN")
               #unless lin.blank?
               #    out << group.raw
               #    out << ""
               #end
            end
            return out
        end
    end
end
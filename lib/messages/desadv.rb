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
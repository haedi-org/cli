module EDIFACT
    class BAPLIEMessage < Message
        def initialize(lines, interchange_version = '4', chars = DEFAULT_CHARS)
            super(lines, interchange_version, chars)
        end

        def debug
            out = []
            for group in @groups do
                if group.name == "GROUP_5"
                #    loc = group.get_segments_by_tag("LOC").first
                #    gid = group.get_segments_by_tag("GID").first
                #    mea = group.get_segments_by_tag("MEA").first
                #    unless loc.blank? || loc.stowage_location.blank?
                #        #out << group.raw
                #        out << gid.goods_item_number.value
                #        unless mea.blank?
                #            out << mea.raw
                #            out << mea.measurement_purpose.readable
                #            out << mea.measurement_value.value
                #            out << mea.measure_unit_qualifier.readable
                #        end
                #        out << "====="
                #    end
                    loc = group.get_segments_by_tag("LOC").first
                    eqd = group.get_segments_by_tag("EQD").first
                    unless loc.blank? || eqd.blank?
                        out << eqd.equipment_qualifier.readable
                        out << eqd.full_empty_indicator.readable
                        out << eqd.equipment_size_and_type.readable
                        out << eqd.equipment_id_number.value
                        unless loc.stowage_location.blank?
                            out << loc.stowage_location.inspect
                        else
                        #    out << loc.location_qualifier.readable
                        end
                        out << "-----"
                    end
                end
            end
            return out
        end
    end
end

# LOC+147+0310002::5'
# GID+72917'
# MEA+WT++KGM:2200'
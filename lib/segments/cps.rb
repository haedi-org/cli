module EDIFACT
    class CPSSegment < Segment
        attr_reader :hierarchical_id_number, :hierarchical_parent_id
        attr_reader :packaging_level

        def initialize(raw, line_no, version = nil, chars = nil)
            super(raw, line_no, version, chars)
            @hierarchical_id_number = get_elements_by_code("7164").first
            @hierarchical_parent_id = get_elements_by_code("7166").first
            @packaging_level = get_elements_by_code("7075").first
        end
    end
end

# 010  7164  Hierarchical id. number  M  1  an..12
# 020  7166  Hierarchical parent id.  C  1  an..12
# 030  7075  Packaging level, coded   C  1  an..3
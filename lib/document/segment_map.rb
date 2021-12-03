module EDIFACT
    SEGMENT_MAP = {
        "UNA" => UNASegment,
        "UNB" => UNBSegment,
        "UNH" => UNHSegment,
        "UNT" => UNTSegment,
        "DTM" => DTMSegment,
        "GIN" => GINSegment,
        "RFF" => RFFSegment,
        "PIA" => PIASegment,
    }
end
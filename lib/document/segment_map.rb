module EDIFACT
    SEGMENT_MAP = {
        "UNA" => UNASegment,
        "UNB" => UNBSegment,
        "UNH" => UNHSegment,
        "UNT" => UNTSegment,
        "DOC" => DOCSegment,
        "DTM" => DTMSegment,
        "EQD" => EQDSegment,
        "FTX" => FTXSegment,
        "GID" => GIDSegment,
        "GIN" => GINSegment,
        "LOC" => LOCSegment,
        "MEA" => MEASegment,
        "NAD" => NADSegment,
        "RFF" => RFFSegment,
        "PIA" => PIASegment,
    }
end
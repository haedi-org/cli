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
        "GIN" => GINSegment,
        "RFF" => RFFSegment,
        "PIA" => PIASegment,
    }
end
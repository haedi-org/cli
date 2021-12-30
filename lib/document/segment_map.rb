module EDIFACT
    SEGMENT_MAP = {
        "UNA" => UNASegment,
        "UNB" => UNBSegment,
        "UNH" => UNHSegment,
        "UNT" => UNTSegment,
        "CPS" => CPSSegment,
        "DOC" => DOCSegment,
        "DTM" => DTMSegment,
        "EQD" => EQDSegment,
        "FTX" => FTXSegment,
        "GID" => GIDSegment,
        "GIN" => GINSegment,
        "LIN" => LINSegment,
        "LOC" => LOCSegment,
        "MEA" => MEASegment,
        "NAD" => NADSegment,
        "PAC" => PACSegment,
        "PIA" => PIASegment,
        "RFF" => RFFSegment,
    }
end
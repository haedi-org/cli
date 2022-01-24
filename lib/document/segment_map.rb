module EDIFACT
    SEGMENT_MAP = {
        "UNA" => UNASegment,
        "UNB" => UNBSegment,
        "UNH" => UNHSegment,
        "UNT" => UNTSegment,
        "ALI" => ALISegment,
        "CPS" => CPSSegment,
        "DOC" => DOCSegment,
        "DTM" => DTMSegment,
        "EQD" => EQDSegment,
        "FTX" => FTXSegment,
        "GID" => GIDSegment,
        "GIN" => GINSegment,
        "IMD" => IMDSegment,
        "LIN" => LINSegment,
        "LOC" => LOCSegment,
        "MEA" => MEASegment,
        "NAD" => NADSegment,
        "PAC" => PACSegment,
        "PAI" => PAISegment,
        "PCI" => PCISegment,
        "PIA" => PIASegment,
        "QTY" => QTYSegment,
        "RFF" => RFFSegment,
        # UNICORN
        "MCR" => MCRSegment,
    }
end
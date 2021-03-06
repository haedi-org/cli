module EDIFACT
    SEGMENT_MAP = {
        "UCI" => UCISegment,
        "UCM" => UCMSegment,
        "UCS" => UCSSegment,
        "UNA" => UNASegment,
        "UNB" => UNBSegment,
        "UNH" => UNHSegment,
        "UNT" => UNTSegment,
        "ALI" => ALISegment,
        "BGM" => BGMSegment,
        "CPS" => CPSSegment,
        "DOC" => DOCSegment,
        "DTM" => DTMSegment,
        "EQD" => EQDSegment,
        "ERC" => ERCSegment,
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
        "RDQ" => RDQSegment,
    }
end
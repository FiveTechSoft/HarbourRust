// keyword abbreviation (probes b45/b45d): a source word matches a pattern
// literal when equal (case-insensitive) or a prefix of at least 4 chars.
#command DISPLAY <x> => ? <x>
#command SAY <x> BYE => ? <x> + 10
function main()
    DISP 1
    DISPLA 2
    DISPLAY 3
    SAY 4 BYE
    return nil

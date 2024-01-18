#include identify_regex.ahk

IdentifyBySyntax(code) {
    static identify_regex := get_identify_regex()
    
    ; If script requires a certain version, use that version!
    If RegExMatch(code, "im)^[ |\t]*#Requires[ |\t]+AutoHotkey[ |\t]+[>|<|=]*v?(?P<ver>1|2)\.", &m)
        return {v: m.ver, r:""}
    
    ; If #Requires not found, try to determine version by regex matching
    p := 1, count_1 := count_2 := 0, version := marks := ''
    while p {
        ; Use try so suppress any PCRE errors that might be thrown
        try
            p := RegExMatch(code, identify_regex, &m, p)
        ; If error is caught, break out of check loop
        catch
            break
            
        ; If no match was found, break out of loop
        if (m = "")
            break
        
        p += m.Len
        if SubStr(m.mark,1,1) = 'v' {
            switch SubStr(m.mark,2,1) {   
                case '1': count_1++
                case '2': count_2++
            }
            if !InStr(marks, m.mark)
                marks .= m.mark ' '
        }
    }
    
    v := 0, marks := Trim(marks)
    if !count_1 && !count_2
        r := "no tell-tale matches"
    else if (count_1 && count_2)
        pat := count_1 > count_2 ? "v1 {1}:{2} - {3}"
            : count_2 > count_1 ? "v2 {2}:{1} - {3}"
            : "? {1}:{2} - {3}"
        ,r := Format(pat, count_1, count_2, marks)
    else v := count_1 ? 1 : 2
        ,r := marks
    return {v:v, r:r}
}


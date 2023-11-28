function convertFieldsDb(oRow)
    local value, i, cKey, hRow := { => }

    for i := 1 to hmg_len(oRow:aRow)
        cKey := oRow:FieldName(i)
        value := oRow:FieldGet(i)
        if ValType(value) == "C"
            value := desacentuar(ansi_to_unicode(value))
        elseif ValType(value) == "D"
            value := Transform(DToS(value), "@R 9999-99-99")
        endif
        hb_hSet(hRow, cKey, value)
    next

return hRow

function DateTime_to_mysql(stringDateTime)
    local dateTime := StrTran(stringDateTime, "T", " ")
    dateTime := StrTran(dateTime, "/", "-")
    dateTime := Left(dateTime, 19)
return dateTime

function string_hb_to_mysql(stringSQL)
Return HMG_UNICODE_TO_ANSI(mysql_escape_string(AllTrim(stringSQL)))

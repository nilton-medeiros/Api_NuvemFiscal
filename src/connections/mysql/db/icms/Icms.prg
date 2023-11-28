#include "hmg.ch"
#include <hbclass.ch>

class TDbIcms
    data pIni
    data pFim
    data count
    method new(ufOrigem, ufDestino) constructor
end class

method new(ufOrigem, ufDestino) class TDbIcms
    local sql := TSQLString():new("SELECT uf_origem, uf_" + ufDestino + " FROM icms ")
    local icms

    ::pIni := 0
    ::pFim := 0
    ::count := 0

    sql:add("WHERE uf_origem IN ('")
    sql:add(ufOrigem + "','" + ufDestino)
    sql:add("') LIMIT 2")

    icms := TQuery():new(sql:value)

    if icms:executed
        ::count := icms:LastRec()
        if (::count == 2)
            if (icms:FieldGet('uf_origem') == ufOrigem)
                ::pIni := icms:FieldGet("uf_" + ufDestino)
            else
                ::pFim := icms:FieldGet("uf_" + ufDestino)
            endif
            icms:Skip()
            if (icms:FieldGet('uf_origem') == ufOrigem)
                ::pIni := icms:FieldGet("uf_" + ufDestino)
            else
                ::pFim := icms:FieldGet("uf_" + ufDestino)
            endif
        else
            saveLog("Consuta a tabela de ICMS não retornou dois registros necessários")
        endif
    endif
    
    icms:Destroy()

return self

#include "hmg.ch"
#include <hbclass.ch>

class TDbUsuarios
    data usuarios
    data ok
    method new() constructor
    method count() setget
end class

method new() class TDbUsuarios
    local dbUsers, sql := TSQLString():new()
    local hRow

    sql:setValue("SELECT user_id as id, ")
    sql:add("user_login AS login, ")
    sql:add("user_senha AS password ")
    sql:add("FROM view_usuarios ")
    sql:add("WHERE user_ativo = TRUE AND perm_grupo = 'Administradores' ")
    sql:add("ORDER BY user_id")

    ::usuarios := {}
    ::ok := false
    dbUsers := TQuery():new(sql:value)

    if dbUsers:executed
        do while !dbUsers:db:Eof()
            hRow := convertFieldsDb(dbUsers:db:GetRow())
            AAdd(::usuarios, TUsuario():new(hRow))
            dbUsers:db:Skip()
        enddo
    endif

    ::ok := !(hmg_len(::usuarios) == 0)
    dbUsers:Destroy()

return self

method count() class TDbUsuarios
return hmg_len(::usuarios)
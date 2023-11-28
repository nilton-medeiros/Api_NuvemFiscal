#include "hmg.ch"
#include "hbclass.ch"

class TMySQLDataSource
    data server readonly
    data user readonly
    data password readonly
    data port readonly
    data database readonly
    data iconStatus init "serverWAIT"
    data connected init false
    data connectionStatus init "Desconectado"
    data mysql as object readonly

    method new(server, user, password, port, database) constructor
    method connect()
    method tryToConnect()
    method disconnect()
    method isSet() inline !Empty(::server) .and. !Empty(::user) .and. !Empty(::password) .and. !Empty(::database)

end class

method new(server, user, password, port, database) class TMySQLDataSource
    ::server := iif(ValType(server) == "C", AllTrim(server), "")
    ::user := iif(ValType(user) == "C", AllTrim(user), "")
    ::password := iif(ValType(password) == "C", password, "")
    ::port := iif(ValType(port) == "C", Val(AllTrim(port)), iif(ValType(port) == "N", port, 3306))
    ::database := iif(ValType(database) == "C", AllTrim(database), ::user)
return self

method connect() class TMySQLDataSource
    local msgError, msgBoxTimeout, hMsg := { => }

    // Tenta conectar pelo menos duas vezes
    if !::tryToConnect() .and. !::tryToConnect()

        if (::mysql == NIL)
            PlayAsterisk()
            msgError := "Não foi possível conectar ao servidor do banco de dados"
            ::disconnect()
            hb_hSet(hMsg, "notifyTooltip", "Servidor indisponível")
            hb_hSet(hMsg, "notifyICON", "serverOFF")
            hb_hSet(hMsg, "showMsg", {"message" => msgError, "title" => "Servidor indisponível!"})
            msgNotify(hMsg)
            saveLog(msgError)
            MsgStop(msgError, "Servidor indisponível ou sem conexão com a internet, tente mais tarde!")
            return false
        elseif ::mysql:NetErr()
            PlayAsterisk()
            msgError := {"Não foi possível conectar ao servidor do banco de dados",;
                hb_eol(),;
                "     Possíveis problemas:", hb_eol(),;
                "        - Parâmentros de conexão inválidos", hb_eol(),;
                "        - Login não permitido", hb_eol(),;
                "        - Senha do Banco de Dados inválida", hb_eol(),;
                "     Erro: ", ::mysql:Error();
            }
            ::disconnect()
            hMsg["notifyTooltip"] := "Sem conexão"
            hMsg["showMsg"] := {"message" => msgError, "title" => "Servidor indisponível!"}
            msgNotify(hMsg)
            saveLog(msgError)
            msgBoxTimeout := MessageBoxTimeout(msgError, "DFeMonitor " + appData:version + ": Falha de Conexão!", MB_ICONERROR + MB_RETRYCANCEL, 300000)
            if (msgBoxTimeout == IDTIMEDOUT) .or. (msgBoxTimeout == IDRETRY)
                if !::tryToConnect()
                    MsgStop(msgError, "Falha de Conexão!")
                    return false
                endif
            else // IDCANCEL
                turnOFF(true)
            endif
        endif

    endif

    ::mysql:selectDB(::database)
    ::connected := !::mysql:NetErr()

    if !::connected

        PlayAsterisk()
        msgError := {'Não foi possível conectar ao Banco de Dados MySQL "' + ::database + '"', hb_eol()+hb_eol(), 'Servidor: ', ::server}
        ::disconnect()
        hMsg["notifyTooltip"] := "Servidor indisponível"
        hMsg["notifyICON"] := "serverOFF"
        hMsg["showMsg"] := {"message" => msgError, "title" => "Servidor indisponível!"}
        msgNotify(hMsg)
        saveLog(msgError)
    else
        ::iconStatus := "serverON"
        ::connectionStatus := "Conectado"
        msgNotify()
        SetProperty("main", "NotifyIcon", "serverON")
        //MsgInfo(mysql_get_host_info(  ::server:nSocket), 'Informações do Host') -- Traz o IP ou localhost
        //MsgInfo(mysql_get_server_info(::server:nSocket), 'Informações do Server') -- Traz a versão do MySQL
    endif

return ::connected

method tryToConnect() class TMySQLDataSource
    SetProperty('main', 'NotifyIcon', 'serverOFF')
    ::disconnect()
    if ::isSet()
       msgNotify({"notifyTooltip" => "Conectando ao servidor..."})
       ::mysql := TMySQLServer():new(::server, ::user, ::password, ::port)
    else
       saveLog("Parametros do banco de dados nao definidos!")
    endif
return !(::mysql == NIL) .and. !::mysql:NetErr()

method disconnect() class TMySQLDataSource
    ::connected := false
    ::connectionStatus := "Desconectado"
    ::iconStatus := "serverOFF"
    if !(::mysql == NIL)
       ::mysql:Destroy()
       ::mysql := NIL
    endif
    msgNotify()
    SetProperty('main', 'NotifyIcon', 'serverOFF')
return self

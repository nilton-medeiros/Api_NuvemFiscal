#include "hmg.ch"
#include <hbclass.ch>

#define MODO_ASSINCRONO .F.

class TAuthNuvemFiscal

    data regPath readonly
    data token
    data expires_in readonly
    data Authorized readonly

    method new() constructor
    method getNewToken()

end class

method new() class TAuthNuvemFiscal
    ::regPath := appData:winRegistryPath
    ::token := CharXor(RegistryRead(::regPath + "nuvemFiscal\token"), "SysWeb2023")
    ::expires_in := StoD(RegistryRead(::regPath + "nuvemFiscal\expires_in"))

    if Empty(::expires_in) .or. (::expires_in < Date())
        // Ainda não tem token ou garante o novo token 2 dias antes de expirar
        ::Authorized := ::getNewToken()
    else
        ::Authorized := true
    endif

return Self

method getNewToken() class TAuthNuvemFiscal
    local lAuth := false, lError := false
    local empresa := appEmpresas:empresas[1]    // as Keys são as mesmas para todas as empresas
    local url := "https://auth.nuvemfiscal.com.br/oauth/token"
    local connection, response
	local content_type := "application/x-www-form-urlencoded"
    local client_id := empresa:nuvemfiscal_client_id
    local client_secret := empresa:nuvemfiscal_client_secret
    local scope := "cte mdfe cnpj empresa cep conta"
    local hResp, objError, msgError, body

    begin sequence
        connection := win_oleCreateObject("MSXML2.ServerXMLHTTP.6.0")   // usa msxml6.dll (esta funciona em Win10/11)
        // connection := win_oleCreateObject("Microsoft.XMLHTTP")       // Usa msxml3.dll (não funciona Win7/10/11)
        if Empty(connection)
            saveLog("Erro na criação do serviço: MSXML2")
            // consoleLog({'win_oleCreateObject("MSXML2.ServerXMLHTTP.6.0") retornou type: ', ValType(connection), hb_eol()})
            lError := true
            Break
        endif
    end sequence

    if lError
        return false
    endif

    begin sequence

        connection:Open("POST", url, MODO_ASSINCRONO)
        connection:SetRequestHeader("Content-Type", content_type)

        /*  Os parâmetros são separados pelo & (ê comercial),
            mas o Harbour interpreta como macro substituição!
            Neste caso, é preciso usar o chr(38) para impor o &
            a cada parâmentro na string body
         */
        body := "grant_type=client_credentials"
        body += chr(38) + "client_id=" + client_id
        body += chr(38) + "client_secret=" + client_secret
        body += chr(38) + "scope=" + scope

        connection:Send(body)
        connection:WaitForResponse(5000)

    recover using objError
        msgError := MsgDebug(connection)
        if (objError:genCode == 0)
            // consoleLog({"Erro de conexão com o site", hb_eol(), hb_eol(), msgError, hb_eol()})
            saveLog({"Erro de conexão com o site", hb_eol(), hb_eol()})
        else
            // consoleLog({"Erro de conexão com o site", hb_eol(), "Error: ", objError:description, hb_eol(), msgError, hb_eol()})
            saveLog({"Erro de conexão com o site", hb_eol(), "Error: ", objError:description, hb_eol()})
        endif
        saveLog({"Erro de conexão com o site", hb_eol(), msgError, hb_eol()})
        lError := true
        Break
    end sequence

    if lError
        return false
    endif

    response := connection:ResponseBody
    // consoleLog(response)
    hResp := hb_jsonDecode(response)

    if hb_HGetRef(hResp, "access_token")
        ::token := hResp["access_token"]
        // Converte os segundos em dia (até segunda ordem da nuvem fiscal, é sempre 2592000's, que dá 30 dias)
        ::expires_in := Date() + hResp["expires_in"]/60/60/24
        ::expires_in := ::expires_in -2 // Menos 2 dias para garantir a renovação antes de expirar efetivamente
        RegistryWrite(::regPath + "nuvemFiscal\token", CharXor(::token, "SysWeb2023"))
        RegistryWrite(::regPath + "nuvemFiscal\expires_in", DtoS(::expires_in))
        lAuth := true
    else
        msgError := MsgDebug(response, hResp)
        //Teste: Passou! | consoleLog({"ResponseBody (hResp) retornou vazio", hb_eol(), msgError})
        saveLog("Falha na autenticação com a API da NuvemFiscal, o responseBody (hResp) retornou vazio")
    endif

return lAuth
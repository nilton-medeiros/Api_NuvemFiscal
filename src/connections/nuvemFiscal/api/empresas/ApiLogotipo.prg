#include "hmg.ch"
#include <hbclass.ch>


class TApiLogotipo

    data tpAmb readonly
    data cnpj readonly
    data token
    data connection
    data connected readonly
    data response readonly
    data httpStatus readonly
    data ContentType readonly
    data baseUrl readonly

    method new(cnpj) constructor
    method Baixar()
    method Enviar(imgLogotipo)
    method Deletar()

end class


method new(empresa) class TApiLogotipo

    ::tpAmb := empresa:tpAmb
    ::cnpj := empresa:cnpj
    ::connected := false
    ::response := ""
    ::httpStatus := 0
    ::ContentType := ""
    ::token := appNuvemFiscal:token

    if Empty(::token)
        saveLog("Token vazio para conexão com a Nuvem Fiscal")
    else
        ::connection := GetMSXMLConnection()
        ::connected := !Empty(::connection)
    endif

    if (::tpAmb == 1)
        // API de Produção
        ::baseUrl := "https://api.nuvemfiscal.com.br/empresas/" + ::cnpj + "/logotipo"
    else
        // API de Teste
        ::baseUrl := "https://api.sandbox.nuvemfiscal.com.br/empresas/" + ::cnpj + "/logotipo"
    endif

return self


method Baixar() class TApiLogotipo
    local res

    if !::connected
        return false
    endif

    // Broadcast Parameters: connection, httpMethod, apiUrl, token, operation, body, content_type, accept
    res := Broadcast(::connection, "GET", ::baseUrl, ::token, "Baixar Logotipo")

    ::httpStatus := res['status']
    ::ContentType := res['ContentType']
    ::response := res['response']

    if res['error']
        saveLog({"Erro ao baixar logotipo na api Nuvem Fiscal", hb_eol(), "Http Status: ", res['status'], hb_eol(), "Content-Type: ", res['ContentType'], hb_eol(), "Response: ", res['response']})
    endif

return !res['error']


method Enviar(imgLogotipo, cExt) class TApiLogotipo
    local res, content_type := "image/png"

    if !::connected
        return false
    endif

    default cExt := "png"

    cExt := Lower(Token(cExt, "."))

    if (cExt == "jpg")
        cExt := "jpeg"
    endif

    content_type := "image/" + cExt

    // Broadcast Parameters: connection, httpMethod, apiUrl, token, operation, body, content_type, accept
    res := Broadcast(::connection, "PUT", ::baseUrl, ::token, "Enviar Logotipo", imgLogotipo, content_type)

    ::httpStatus := res['status']
    ::ContentType := res['ContentType']
    ::response := res['response']

    if res['error']
        saveLog({"Erro ao enviar logotipo na api Nuvem Fiscal", hb_eol(), "Http Status: ", res['status'], hb_eol(),;
                 "ContentType: ", res['ContentType'], hb_eol(), "Response: ", res['response']})
    endif

return !res['error']


method Deletar() class TApiLogotipo
    local res

    // Broadcast Parameters: connection, httpMethod, apiUrl, token, operation, body, content_type, accept
    res := Broadcast(::connection, "DELETE", ::baseUrl, ::token, "Deletar Logotipo")

    ::httpStatus := res['status']
    ::ContentType := res['ContentType']
    ::response := res['response']

    if res['error']
        saveLog({"Erro ao deletar logotipo na api Nuvem Fiscal", hb_eol(), "Http Status: ", res['status'], hb_eol(), "Content-Type: ", res['ContentType'], hb_eol(), "Response: ", res['response']})
    endif

return !res['error']

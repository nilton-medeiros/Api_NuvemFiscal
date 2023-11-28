#include "hmg.ch"
#include <hbclass.ch>


class TApiCertificado

    data tpAmb readonly
    data cnpj readonly
    data token
    data connection
    data connected readonly
    data response readonly
    data httpStatus readonly
    data ContentType readonly
    data baseUrl readonly

    method new(empresa) constructor
    method Consultar()
    method Cadastrar(certificado, password)
    method Deletar()

end class


method new(empresa) class TApiCertificado

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
        ::baseUrl := "https://api.nuvemfiscal.com.br/empresas/" + ::cnpj + "/certificado"
    else
        ::baseUrl := "https://api.sandbox.nuvemfiscal.com.br/empresas/" + ::cnpj + "/certificado"
    endif

return self


method Consultar() class TApiCertificado
    local res

    if !::connected
        return false
    endif

    // Broadcast Parameters: connection, httpMethod, apiUrl, token, operation, body, content_type, accept
    res := Broadcast(::connection, "GET", ::baseUrl, ::token, "Consultar Certificado")

    ::httpStatus := res['status']
    ::ContentType := res['ContentType']
    ::response := res['response']

    if res['error']
        saveLog({"Erro ao consultar certificado na api Nuvem Fiscal", hb_eol(), "Http Status: ", res['status'], hb_eol(), "Content-Type: ", res['ContentType'], hb_eol(), "Response: ", res['response']})
    endif

return !res['error']


method Cadastrar(certificado, password) class TApiCertificado
    local res, body

    if !::connected
        return false
    endif

    // Request Body
    body := '{' + hb_eol()
    body += '  "certificado": "' + certificado + '",' + hb_eol()
    body += '  "password": "' + password + '"' + hb_eol()
    body += '}'

    // Broadcast Parameters: connection, httpMethod, apiUrl, token, operation, body, content_type, accept
    res := Broadcast(::connection, "PUT", ::baseUrl, ::token, "Cadastrar Certificado", body, "application/json")

    ::httpStatus := res['status']
    ::ContentType := res['ContentType']
    ::response := res['response']

    if res['error']
        saveLog({"Erro ao cadastrar certificado na api Nuvem Fiscal", hb_eol(), "Http Status: ", res['status'], hb_eol(),;
                 "ContentType: ", res['ContentType'], hb_eol(), "Response: ", res['response']})
    endif

return !res['error']


method Deletar() class TApiCertificado
    local res

    // Broadcast Parameters: connection, httpMethod, apiUrl, token, operation, body, content_type, accept
    res := Broadcast(::connection, "DELETE", ::baseUrl, ::token, "Deletar Certificado")

    ::httpStatus := res['status']
    ::ContentType := res['ContentType']
    ::response := res['response']

    if res['error']
        saveLog({"Erro ao deletar certificado na api Nuvem Fiscal", hb_eol(), "Http Status: ", res['status'], hb_eol(), "Content-Type: ", res['ContentType'], hb_eol(), "Response: ", res['response']})
    endif

return !res['error']

#include "hmg.ch"
#include <hbclass.ch>


class TApiCertificado

    data cnpj readonly
    data token protected
    data connection protected
    data connected readonly
    data response readonly
    data responseType readonly
    data httpStatus readonly
    data ContentType readonly

    method new(cnpj) constructor
    method Consultar()
    method Cadastrar(certificado, password)
    method Deletar()

end class


method new(cnpj) class TApiCertificado

    ::cnpj := cnpj
    ::token := ""
    ::connected := false
    ::response := ""
    ::responseType := ""
    ::httpStatus := 0
    ::ContentType := ""

    begin sequence

        ::connection := win_oleCreateObject("MSXML2.ServerXMLHTTP.6.0")

        if Empty(::connection)
            saveLog("Erro na criação do serviço: MSXML2")
            consoleLog({'win_oleCreateObject("MSXML2.ServerXMLHTTP.6.0") retornou type: ', ValType(connect), hb_eol()})
            Break
        endif

        ::token := appNuvemFiscal:token

        if Empty(::token)
            saveLog("Token vazio para conexão com a Nuvem Fiscal")
        else
            ::connected := true
        endif

    end sequence

return self


method Consultar() class TApiCertificado
    local res, apiUrl

    if !::connected
        return false
    endif

    if empresa:tpAmb == "1"
        API de Produção
        apiUrl := "https://api.nuvemfiscal.com.br/empresas/" + ::cnpj + "/certificado"
    else
        API de Teste
        apiUrl := "https://api.sandbox.nuvemfiscal.com.br/empresas/" + ::cnpj + "/certificado"
    endif

    res := Broadcast(::connection, "GET", apiUrl, ::token, "Consultar Certificado")

    ::httpStatus := res['status']
    ::ContentType := res['ContentType']
    ::response := res['response']

    if res['error']
        saveLog({"Erro ao consultar certificado na api Nuvem Fiscal", hb_eol(), "Http Status: ", res['status'], hb_eol(), "Content-Type: ", res['ContetType'], hb_eol(), "Response: ", res['response']})
    endif

return !res['error']


method Cadastrar(certificado, password) class TApiCertificado
    local res, apiUrl, body

    if !::connected
        return false
    endif

    if empresa:tpAmb == "1"
        API de Produção
        apiUrl := "https://api.nuvemfiscal.com.br/empresas/" + ::cnpj + "/certificado"
    else
        API de Teste
        apiUrl := "https://api.sandbox.nuvemfiscal.com.br/empresas/" + ::cnpj + "/certificado"
    endif

    body := '{' + hb_eol()
    body += '  "certificado": "' + certificado + '",' + hb_eol()
    body += '  "password": "' + password + '"' + hb_eol()
    body += '}'

    res := Broadcast(::connection, "PUT", apiUrl, ::token, "Cadastrar Certificado", body)

    ::httpStatus := res['status']
    ::ContentType := res['ContentType']
    ::response := res['response']

    if res['error']
        saveLog({"Erro ao cadastrar certificado na api Nuvem Fiscal", hb_eol(), "Http Status: ", res['status'], hb_eol(),;
                 "ContentType: ", res['ContentType'], hb_eol(), "Response: ", res['response']})
    endif

return !res['error']


method Deletar() class TApiCertificado
    local apiUrl, res

    if empresa:tpAmb == "1"
        API de Produção
        apiUrl := "https://api.nuvemfiscal.com.br/empresas/" + ::cnpj + "/certificado"
    else
        API de Teste
        apiUrl := "https://api.sandbox.nuvemfiscal.com.br/empresas/" + ::cnpj + "/certificado"
    endif

    res := Broadcast(::connection, "DELETE", apiUrl, ::token, "Deletar Certificado")

    ::httpStatus := res['status']
    ::ContentType := res['ContentType']
    ::response := res['response']

    if res['error']
        saveLog({"Erro ao deletar certificado na api Nuvem Fiscal", hb_eol(), "Http Status: ", res['status'], hb_eol(), "Content-Type: ", res['ContetType'], hb_eol(), "Response: ", res['response']})
    endif

return !res['error']

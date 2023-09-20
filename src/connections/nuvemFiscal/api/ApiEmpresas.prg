#include "hmg.ch"
#include <hbclass.ch>


class TApiEmpresas

    data token protected
    data connection protected
    data connected readonly
    data body readonly
    data response readonly
    data responseType readonly
    data httpStatus readonly
    data ContentType readonly

    method new() constructor
    method Alterar(empresa)
    method Cadastrar(empresa)
    method Consultar(empresa)
    method Deletar(empresa)
    method defineBody(empresa)

end class


method new() class TApiEmpresas

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


method Cadastrar(empresa) class TApiEmpresas
    local res, apiUrl

    if !::connected
        return false
    endif

    if empresa:tpAmb == "1"
        // API de Produção
        apiUrl := "https://api.nuvemfiscal.com.br/empresas"
    else
        // API de Teste
        apiUrl := "https://api.sandbox.nuvemfiscal.com.br/empresas"
    endif

    ::defineBody(empresa)

    res := Broadcast(::connection, "POST", apiUrl, ::token, "Cadastrar Empresa", ::body)

    ::httpStatus := res['status']
    ::ContentType := res['ContentType']
    ::response := res['response']

    if res['error']
        saveLog({"Erro ao cadastrar empresa na api Nuvem Fiscal", hb_eol(), "Http Status: ", res['status'], hb_eol(),;
                 "Content-Type: ", res['ContetType'], hb_eol(), "Response: ", res['response']})
    endif
return !res['error']


method Consultar(empresa) class TApiEmpresas
    local res, apiUrl

    if !::connected
        return false
    endif

    if empresa:tpAmb == "1"
        // API de Produção
        apiUrl := "https://api.nuvemfiscal.com.br/empresas/" + empresa:CNPJ
    else
        // API de Teste
        apiUrl := "https://api.sandbox.nuvemfiscal.com.br/empresas/" + empresa:CNPJ
    endif

    res := Broadcast(::connection, "GET", apiUrl, ::token, "Consultar Empresa")

    ::httpStatus := res['status']
    ::ContentType := res['ContentType']
    ::response := res['response']

    if res['error']
        saveLog({"Erro ao consultar empresa na api Nuvem Fiscal", hb_eol(), "Http Status: ", res['status'], hb_eol(),;
                 "Content-Type: ", res['ContetType'], hb_eol(), "Response: ", res['response']})
    endif
return !res['error']


method Alterar(empresa) class TApiEmpresas
    local res, apiUrl

    if !::connected
        return false
    endif

    if empresa:tpAmb == "1"
        // API de Produção
        apiUrl := "https://api.nuvemfiscal.com.br/empresas/" + empresa:CNPJ
    else
        // API de Teste
        apiUrl := "https://api.sandbox.nuvemfiscal.com.br/empresas/" + empresa:CNPJ
    endif

    ::defineBody(empresa)

    res := Broadcast(::connection, "PUT", apiUrl, ::token, "Alterar Empresa", ::body)

    ::httpStatus := res['status']
    ::ContentType := res['ContentType']
    ::response := res['response']

    if res['error']
        saveLog({"Erro ao alterar empresa na api Nuvem Fiscal", hb_eol(), "Http Status: ", res['status'], hb_eol(),;
                 "Content-Type: ", res['ContetType'], hb_eol(), "Response: ", res['response']})
    endif
return !res['error']


method defineBody(empresa) class TApiEmpresas
    ::body := '{' + hb_eol()
    ::body += '  "cpf_cnpj": "' + empresa:cnpj + '",' + hb_eol()
    ::body += '  "inscricao_estadual": "' + empresa:IE + '",' + hb_eol()
    ::body += '  "inscricao_municipal": "' + empresa:IM + '",' + hb_eol()
    ::body += '  "nome_razao_social": "' + empresa:xNome + '",' + hb_eol()
    ::body += '  "nome_fantasia": "' + empresa:xFant + '",' + hb_eol()
    ::body += '  "fone": "' + empresa:fone + '",' + hb_eol()
    ::body += '  "email": "' + empresa:email + '",' + hb_eol()
    ::body += '  "endereco": {' + hb_eol()
    ::body += '    "logradouro": "' + empresa:xLgr + '",' + hb_eol()
    ::body += '    "numero": "' + empresa:nro + '",' + hb_eol()
    ::body += '    "complemento": "' + empresa:xCpl + '",' + hb_eol()
    ::body += '    "bairro": "' + empresa:xBairro + '",' + hb_eol()
    ::body += '    "codigo_municipio": "' + empresa:cMunEnv + '",' + hb_eol()
    ::body += '    "cidade": "' + empresa:xMunEnv + '",' + hb_eol()
    ::body += '    "uf": "' + empresa:UF + '",' + hb_eol()
    ::body += '    "cep": "' + empresa:CEP + '"' + hb_eol()
    ::body += '  }' + hb_eol()
    ::body += '}'
return nil

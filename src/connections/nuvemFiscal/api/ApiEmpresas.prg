#include "hmg.ch"
#include <hbclass.ch>


class TApiEmpresas

    data token
    data connection
    data connected readonly
    data body readonly
    data response readonly
    data httpStatus readonly
    data ContentType readonly

    method new() constructor
    method Alterar(empresa)
    method Cadastrar(empresa)
    method Consultar(empresa)
    method defineBody(empresa)
    method putSetupCTe(empresa)

end class


method new() class TApiEmpresas

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

return self


method Cadastrar(empresa) class TApiEmpresas
    local res, apiUrl

    if !::connected
        return false
    endif

    // Debug: Integração em teste, remover os comentários do laço if/endif abaixo
    // if empresa:tpAmb == 1
        // API de Produção
        // apiUrl := "https://api.nuvemfiscal.com.br/empresas"
    // else
        // API de Teste
        apiUrl := "https://api.sandbox.nuvemfiscal.com.br/empresas"
    // endif

    // Request Body
    ::defineBody(empresa)

    // Broadcast Parameters: connection, httpMethod, apiUrl, token, operation, body, content_type, accept
    res := Broadcast(::connection, "POST", apiUrl, ::token, "Cadastrar Empresa", ::body, "application/json")

    ::httpStatus := res['status']
    ::ContentType := res['ContentType']
    ::response := res['response']

    if res['error']
        saveLog({"Erro ao cadastrar empresa na api Nuvem Fiscal", hb_eol(), "Http Status: ", res['status'], hb_eol(),;
                 "Content-Type: ", res['ContetType'], hb_eol(), "Response: ", res['response']})
    else
        ::putSetupCTe(empresa)
    endif

return !res['error']


method Consultar(empresa) class TApiEmpresas
    local res, apiUrl

    if !::connected
        return false
    endif

    // Debug: Integração em teste, remover os comentários do laço if/endif abaixo
    // if empresa:tpAmb == 1
        // API de Produção
        // apiUrl := "https://api.nuvemfiscal.com.br/empresas/" + empresa:CNPJ
    // else
        // API de Teste
        apiUrl := "https://api.sandbox.nuvemfiscal.com.br/empresas/" + empresa:CNPJ
    // endif

    // Broadcast Parameters: connection, httpMethod, apiUrl, token, operation, body, content_type, accept
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

    // Debug: Integração em teste, remover os comentários do laço if/endif abaixo
    // if empresa:tpAmb == 1
        // API de Produção
        // apiUrl := "https://api.nuvemfiscal.com.br/empresas/" + empresa:CNPJ
    // else
        // API de Teste
        apiUrl := "https://api.sandbox.nuvemfiscal.com.br/empresas/" + empresa:CNPJ
    // endif
    // Request Body
    ::defineBody(empresa)

    // Broadcast Parameters: connection, httpMethod, apiUrl, token, operation, body, content_type, accept
    res := Broadcast(::connection, "PUT", apiUrl, ::token, "Alterar Empresa", ::body, "application/json")

    ::httpStatus := res['status']
    ::ContentType := res['ContentType']
    ::response := res['response']

    if res['error']
        saveLog({"Erro ao alterar empresa na api Nuvem Fiscal", hb_eol(), "Http Status: ", res['status'], hb_eol(),;
                 "Content-Type: ", res['ContetType'], hb_eol(), "Response: ", res['response']})
    else
        ::putSetupCTe(empresa)
    endif

return !res['error']

// Request Body
method defineBody(empresa) class TApiEmpresas
    // Refatorar para Hash Table e depois usar hb_jsonEncode(hBody, 4)
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

method putSetupCTe(empresa) class TApiEmpresas
    local res, apiUrl, hBody

    if !::connected
        return false
    endif

    // Debug: Integração em teste, remover os comentários do laço if/endif abaixo
    // if empresa:tpAmb == 1
        // API de Produção
        // apiUrl := "https://api.nuvemfiscal.com.br/empresas/" + empresa:CNPJ + "/cte"
    // else
        // API de Teste
        apiUrl := "https://api.sandbox.nuvemfiscal.com.br/empresas/" + empresa:CNPJ + "/cte"
    // endif

    // Request Body
    hBody := {=>}
    hBody["CRT"] := empresa:CRT
    hBody["ambiente"] := "homologacao"     // Debug: Após testes, substituir por iif(empresa:tpAmb == 1, "producao", "homologacao")
    ::body := hb_jsonEncode(hBody, 4)

    // Broadcast Parameters: connection, httpMethod, apiUrl, token, operation, body, content_type, accept
    res := Broadcast(::connection, "PUT", apiUrl, ::token, "Alterar configurações de CT-e", ::body, "application/json")

    ::httpStatus := res['status']
    ::ContentType := res['ContentType']
    ::response := res['response']

    if res['error']
        saveLog({"Erro ao alterar configuração de CT-e na api Nuvem Fiscal", hb_eol(), "Http Status: ", res['status'], hb_eol(),;
                 "Content-Type: ", res['ContetType'], hb_eol(), "Response: ", res['response']})
    endif

return !res['error']

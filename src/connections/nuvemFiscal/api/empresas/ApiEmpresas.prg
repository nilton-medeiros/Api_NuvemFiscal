#include "hmg.ch"
#include <hbclass.ch>


class TApiEmpresas

    data empresa
    data token
    data connection
    data connected readonly
    data body readonly
    data response readonly
    data httpStatus readonly
    data ContentType readonly
    data baseUrl readonly
    data baseUrlCnpj readonly

    method new(empresa) constructor
    method Alterar()
    method Cadastrar()
    method Consultar()
    method defineBody()
    method putSetupCTe()

end class

method new(empresa) class TApiEmpresas

    ::empresa := empresa
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

    if (::empresa:tpAmb == 1)
        // API de Produção
        ::baseUrl := "https://api.nuvemfiscal.com.br/empresas"
    else
        // API de Teste
        ::baseUrl := "https://api.sandbox.nuvemfiscal.com.br/empresas"
    endif

    ::baseUrlCnpj := ::baseUrl + "/" + ::empresa:CNPJ

return self


method Cadastrar() class TApiEmpresas
    local res

    if !::connected
        return false
    endif

    // Request Body
    ::defineBody()

    // Broadcast Parameters: connection, httpMethod, apiUrl, token, operation, body, content_type, accept
    res := Broadcast(::connection, "POST", ::baseUrl, ::token, "Cadastrar Empresa", ::body, "application/json")

    ::httpStatus := res['status']
    ::ContentType := res['ContentType']
    ::response := res['response']

    if res['error']
        saveLog({"Erro ao cadastrar empresa na api Nuvem Fiscal", hb_eol(), "Http Status: ", res['status'], hb_eol(),;
                 "Content-Type: ", res['ContentType'], hb_eol(), "Response: ", res['response']})
    else
        ::putSetupCTe()
    endif

return !res['error']


method Consultar() class TApiEmpresas
    local res

    if !::connected
        return false
    endif

    // Broadcast Parameters: connection, httpMethod, apiUrl, token, operation, body, content_type, accept
    res := Broadcast(::connection, "GET", ::baseUrlCnpj, ::token, "Consultar Empresa")

    ::httpStatus := res['status']
    ::ContentType := res['ContentType']
    ::response := res['response']

    if res['error']
        saveLog({"Erro ao consultar empresa na api Nuvem Fiscal", hb_eol(), "Http Status: ", res['status'], hb_eol(),;
                 "Content-Type: ", res['ContentType'], hb_eol(), "Response: ", res['response']})
    endif

return !res['error']


method Alterar() class TApiEmpresas
    local res, apiUrl

    if !::connected
        return false
    endif

    // Request Body
    ::defineBody()

    // Broadcast Parameters: connection, httpMethod, apiUrl, token, operation, body, content_type, accept
    res := Broadcast(::connection, "PUT", ::baseUrlCnpj, ::token, "Alterar Empresa", ::body, "application/json")

    ::httpStatus := res['status']
    ::ContentType := res['ContentType']
    ::response := res['response']

    if res['error']
        saveLog({"Erro ao alterar empresa na api Nuvem Fiscal", hb_eol(), "Http Status: ", res['status'], hb_eol(),;
                 "Content-Type: ", res['ContentType'], hb_eol(), "Response: ", res['response']})
    else
        ::putSetupCTe()
    endif

return !res['error']

// Request Body
method defineBody() class TApiEmpresas
    local hBody := {=>}, hEnde := {=>}

    hBody["cpf_cnpj"] := ::empresa:cnpj
    hBody["inscricao_estadual"] := ::empresa:IE
    hBody["inscricao_municipal"] := ::empresa:IM
    hBody["nome_razao_social"] := ::empresa:xNome
    hBody["nome_fantasia"] := ::empresa:xFant
    hBody["fone"] := ::empresa:fone
    hBody["email"] := ::empresa:email
    hEnde["logradouro"] := ::empresa:xLgr
    hEnde["numero"] := ::empresa:nro
    hEnde["complemento"] := ::empresa:xCpl
    hEnde["bairro"] := ::empresa:xBairro
    hEnde["codigo_municipio"] := ::empresa:cMunEnv
    hEnde["cidade"] := ::empresa:xMunEnv
    hEnde["uf"] := ::empresa:UF
    hEnde["cep"] := ::empresa:CEP
    hBody["endereco"] := hEnde

    ::body := hb_jsonEncode(hBody, 4)
    hBody := hEnder := nil

return nil

method putSetupCTe() class TApiEmpresas
    local res, hBody, apiUrl := ::baseUrlCnpj + "/cte"

    if !::connected
        return false
    endif

    // Request Body
    hBody := {=>}
    hBody["CRT"] := ::empresa:CRT
    hBody["ambiente"] := iif(::empresa:tpAmb == 1, "producao", "homologacao")
    ::body := hb_jsonEncode(hBody, 4)

    // Broadcast Parameters: connection, httpMethod, apiUrl, token, operation, body, content_type, accept
    res := Broadcast(::connection, "PUT", apiUrl, ::token, "Alterar configurações de CT-e", ::body, "application/json")

    ::httpStatus := res['status']
    ::ContentType := res['ContentType']
    ::response := res['response']

    if res['error']
        saveLog({"Erro ao alterar configuração de CT-e na api Nuvem Fiscal", hb_eol(), "Http Status: ", res['status'], hb_eol(),;
                 "Content-Type: ", res['ContentType'], hb_eol(), "Response: ", res['response']})
    endif

return !res['error']

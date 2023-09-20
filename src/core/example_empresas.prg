/*
    Exemplo de como usar a classe TApiEmpresa para integrar com a Nuvem Fiscal
*/

procedure main()
    local authNuvemFiscal := TAuthNuvemFiscal():new()
    local apiEmpresa AS OBJECT, empresa AS OBJECT
    local id, hResp, msgRetorno    // Isto é um exemplo

    if !authNuvemFiscal:Authorized
        // QUIT: Mensagem: Falha na Autorização
        RELEASE ALL
    endif

    if Empty(authNuvemFiscal:token)
        // QUIT: Mensagem: Token de acesso inválido
        RELEASE ALL
    endif

    apiEmpresa := TApiEmpresas():new()
    empresa := db_empresa(id := 1) // Exemplo fake de Objeto com todos os campos para compor o Request Body em json


    // Cadastrando uma Empresa Emitente --------------------------------------------------------------

    if apiEmpresa:Cadastrar(empresa)
        // Status entre 200 à 299
        // Se a expresa não exite na nuvem fiscal, será
        MsgBox('Empresa Emitente cadastrada com baita sucesso!')
    else
        // Erro entre 400 à 499
        if apiEmpresa:ContentType == 'json'    // Retornou um json padrão do erro
            // Converta o json string para um array Hash
            hResp := jsonDecode(apiEmpresa:response)    // Ver logo abaixo esta função jsonDecode()
            msgRetorno := "Código: " + hResp['error']['code'] + hb_eol()
            msgRetorno += "Mensagem: " + hResp['error']['message']
        else
            // Erro não padrão desconhecido, texto original da Sefaz/prefeitura
            msgRetorno := apiEmpresa:response
        endif
        MsgExclamation(msgRetorno, "Falha ao cadastrar empresa!")
    endif


    // Alterando uma Empresa Emitente ---------------------------------------------------------------------------
    // Só muda o método "Cadastrar" para "Alterar", mais nada.

    if apiEmpresa:Alterar(empresa)
        // Status entre 200 à 299
        // Se a expresa não exite na nuvem fiscal, será
        MsgBox('Empresa Emitente alterada com baita sucesso!')
    else
        // Erro entre 400 à 499
        if apiEmpresa:ContentType == 'json'    // Retornou um json padrão do erro
            // Converta o json string para um array Hash
            hResp := jsonDecode(apiEmpresa:response)    // Ver logo abaixo esta função jsonDecode()
            msgRetorno := "Código: " + hResp['error']['code'] + hb_eol()
            msgRetorno += "Mensagem: " + hResp['error']['message']  // É retornado também um array de errors, querendo, vc pode tratar isso também
        else
            // Erro não padrão desconhecido, texto original da Sefaz/prefeitura
            msgRetorno := apiEmpresa:response
        endif
        MsgExclamation(msgRetorno, "Falha ao alterar empresa!")
    endif


    // Deletando uma Empresa emitente ---------------------------------------------------------------------------

    if apiEmpresa:Deletar(empresa)
        MsgBox("Empresa deletada com byta sucesso!")
    else
        // Erro entre 400 à 499
        if apiEmpresa:ContentType == 'json'    // Retornou um json padrão do erro
            // Converta o json string para um array Hash
            hResp := jsonDecode(apiEmpresa:response)    // Ver logo abaixo esta função jsonDecode()
            msgRetorno := "Código: " + hResp['error']['code'] + hb_eol()
            msgRetorno += "Mensagem: " + hResp['error']['message']
        else
            // Erro não padrão desconhecido: Content-type == 'text'
            msgRetorno := apiEmpresa:response
        endif
        MsgExclamation(msgRetorno, "Falha ao deletar empresa!")
    endif

    /*
        Consultar Empresas (Traz uma lista de empresas emitentes)
        Não implementei porque não há necessidade em minha aplicação de consultar algo que já veio do banco de dados da aplicação.
        Mas caso tenha interesse, é simples e é só seguir a documentação da Nuvem Fiscal em: https://dev.nuvemfiscal.com.br/docs/api#tag/Empresa/operation/ListarEmpresas
        É retornado um array de objetos do tipo Empresa, atentar na consulta para os parâmetros top e skip.
    */


    // Consultar uma empresa ------------------------------------------------------------------------------------

    if apiEmpresa:Consultar(empresa)
        // Empresa consultada: retorna o json da empresa conforme documentação
        empresa := jsonDecode(apiEmpresa:response)
    else
        // Erro entre 400 à 499
        if apiEmpresa:ContentType == 'json'    // Retornou um json padrão do erro
            // Converta o json string para um array Hash
            hResp := jsonDecode(apiEmpresa:response)    // Ver logo abaixo esta função jsonDecode()
            msgRetorno := "Código: " + hResp['error']['code'] + hb_eol()
            msgRetorno += "Mensagem: " + hResp['error']['message']
        else
            // Erro não padrão desconhecido: Content-type == 'text'
            msgRetorno := apiEmpresa:response
        endif
        MsgExclamation(msgRetorno, "Falha ao consultar empresa!")
    endif

return

function jsonDecode(jsonString)
    local bytes, jsonHash
    bytes := hb_jsonDecode(jsonString, @jsonHash)
    if (bytes == 0)
        jsonHash := { => }  // Hash vazio
    endif
return jsonHash
/*
    Exemplo de como usar a classe TApiEmpresa para integrar com a Nuvem Fiscal
*/

procedure main()
    local authNuvemFiscal := TAuthNuvemFiscal():new()
    local apiCertificado AS OBJECT, emitente AS OBJECT
    local id, hResp, msgRetorno
    local certificadoDigitalEncode64, tudoCerto, password, response

    if !authNuvemFiscal:Authorized
        // QUIT: Mensagem: Falha na Autorização, as msg de erros são salvas em um log, ver class TAuthNuvemFiscal
        RELEASE ALL
    endif

    if Empty(authNuvemFiscal:token)
        // QUIT: Mensagem: Token de acesso inválido
        RELEASE ALL
    endif

    emitente := db_empresa(id := 1) // Exemplo fake de Objeto com todos os campos para compor o Request Body em json
    apiCertificado := TApiCertificado():new(emitente:CNPJ)


    /*
        ==================================
        Cadastrando um Certificado Digital
        ==================================
    */

    certificadoDigitalEncode64 := obtemCertificadoBase64()   // Ver logo abaixo esta função

    // O CNPJ do emitente já foi passado para o construtor new(cnpj)
    tudoCerto := apiCertificado:Cadastrar(certificadoDigitalEncode64, password := "xyzSenha123")

    if tudoCerto
        response := jsonDecode(apiCertificado:response)
        ? response['nome_razao_social']
        ? response['subject_name']
        ? response['issuer_name']   // Emissor do certificado
        ? response['serial_number']
        // Informações adicionais
        ? apiCertificado:httpStatus     // Status: Number 200 à 299 ou 400 à 599
        ? apiCertificado:ContentType    // Content-Type: "json" ou "text"
        ? apiCertificado:response       // string json bruto
    else
        // Deu ruim!
        if apiCertificado:ContentType == "json"
            response := jsonDecode(certificado:response)
            msgRetorno := "codigo: " + response['error']['code'] + hb_eol()
            msgRetorno += "Menssagem: " + response['error']['message']
        else    // Content-Type: text
            msgRetorno := certificado:response  // Texto bruto, contém informações mais detalhada do erro desconhecido
        endif
        saveLog(msgRetorno)
    endif


    /*
        ===============================================================================================
        Deletando um Certificado Digital, o CNPJ do emitente já foi passado para o construtor new(cnpj)
        ===============================================================================================
    */

    if apiCertificado:Deletar()
        MsgBox("Certificado Digital deletado com byta sucesso!")
    else
        // Erro entre 400 à 599
        if apiCertificado:ContentType == 'json'    // Retornou um json padrão do erro
            // Converta o json string para um array Hash
            hResp := jsonDecode(apiCertificado:response)    // Ver logo abaixo esta função jsonDecode()
            msgRetorno := "Código: " + hResp['error']['code'] + hb_eol()
            msgRetorno += "Mensagem: " + hResp['error']['message']
        else
            // Erro não padrão desconhecido: Content-type == 'text'
            msgRetorno := apiCertificado:response
        endif
        MsgExclamation(msgRetorno, "Falha ao deletar certificado!")
    endif


    /*
        ==========================
        Consultando um Certificado
        ==========================
    */

    if apiCertificado:Consultar()

        // Empresa consultada: retorna o json com informações detalhada do certificado aceito!
        // https://dev.nuvemfiscal.com.br/docs/api#tag/Empresa/operation/ConsultarCertificadoEmpresa

        response := jsonDecode(apiCertificado:response)

        ? response['nome_razao_social']
        ? response['subject_name']
        ? response['issuer_name']   // Emissor do certificado
        ? response['serial_number']

        // Informações adicionais
        ? apiCertificado:httpStatus     // Status: Number 200 à 299 ou 400 à 599
        ? apiCertificado:ContentType    // Content-Type: "json" ou "text"
        ? apiCertificado:response       // string json bruto

    else

        // Erro entre 400 à 599
        if apiCertificado:ContentType == 'json'    // Retornou um json padrão do erro
            // Converta o json string para um array Hash
            hResp := jsonDecode(apiCertificado:response)    // Ver logo abaixo esta função jsonDecode()
            msgRetorno := "Código: " + hResp['error']['code'] + hb_eol()
            msgRetorno += "Mensagem: " + hResp['error']['message']
        else
            // Erro não padrão desconhecido: Content-type == 'text'
            msgRetorno := apiCertificado:response
        endif

        MsgExclamation(msgRetorno, "Falha ao consultar certificado!")

    endif

return

function obtemCertificadoBase64()
    local fileLoaded := hb_MemoRead("C:\example\certificados\CertificaoEmpresa1.pfx")

    /*
         Infelizmente a função hb_Base64EncodeFile() não funciona no Harbour, deveria,
         mas na compilação não encontra ela, talvez seja problema de versão do Harbour,
         estou utilizado Harbour 3.2.0dev (r1703241902) que veio com a HMG. Se for o seu caso,
         substitua hb_Base64EncodeFile() por hb_Base64Encode(), mas antes tem que carregar
         o conteúdo do arquivo .PFX/.P12 para uma string com hb_MemoRead(), se não você vai cair no erro
         de passar apenas o nome do arquivo ao invés do esperado conteúdo.
    */

return HB_Base64Encode(fileLoaded)


function jsonDecode(jsonString)
    local bytes, jsonHash
    bytes := hb_jsonDecode(jsonString, @jsonHash)
    if (bytes == 0)
        jsonHash := { => }  // Hash vazio
    endif
return jsonHash

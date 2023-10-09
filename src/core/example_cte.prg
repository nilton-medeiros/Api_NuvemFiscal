/*
    Exemplo de como usar a classe TApiEmpresa para integrar com a Nuvem Fiscal
*/

#define true .T.
#define false .F.

procedure main()
    local apiCTe AS OBJECT, cte AS OBJECT
    local id, hResp, msgRetorno, recebido, emitido, startTimer    // Isto é um exemplo
    local aError, error

    // appNuvemFiscal: var Public utilizado nas apis para autenticação na nuvem fiscal
    public appNuvemFiscal := TAuthNuvemFiscal():new()

    if !appNuvemFiscal:Authorized
        // QUIT: Mensagem: Falha na Autorização
        RELEASE ALL
    endif

    if Empty(appNuvemFiscal:token)
        // QUIT: Mensagem: Token de acesso inválido
        RELEASE ALL
    endif

    cte := db_ctes(id := 1) // Exemplo fake de Objeto-interface com todos os campos do CTe para compor o Request Body em json

    apiCTe := TApiCTe():new(cte)

    // Emitindo um CTe --------------------------------------------------------------

    recebido := apiCTe:Emitir()
    emitido := false

    if recebido

        // CTe foi recebido, verifica se foi autorizado ou rejeitado
        emitido := (apiCTe:status == "autorizado")

        if !emitido

            // Normalmente a api da Nuvem Fiscal retorna status "pendente" segundo orientação da nv, nos testes (homologação) retornam direto 'autorizado'
            sysWait(2)  // Aguarda 2 segundos para obter autorizado ou erro

            recebido := apiCTe:Consultar()
            startTimer := Seconds()

            do while recebido .and. (apiCTe:status == 'pendente') .and. (Seconds() - startTimer < 10)
                // Situação pouco provável, porem não impossível: Insiste obter informações por até 10 segundos
                sysWait(2)
                recebido := apiCTe:Consultar()
            enddo

            emitido := (apiCTe:status == "autorizado")
            consoleLog("emitido: " + iif(emitido, "SIM", "NÃO"))  // Debug

        endif

        if emitido
            // Atualiza informações no data base do seu cte emitido
            cte:setSituacao(apiCTe:status)
            cte:setUpdateCte('cte_chave', apiCTe:chave)
            cte:setUpdateCte('cte_protocolo_autorizacao', apiCTe:numero_protocolo)
            cte:setUpdateCte('nuvemfiscal_uuid', apiCTe:nuvemfiscal_uuid)
            // Prepara os campos da tabela ctes_eventos para receber os updates
            if !Empty(apiCTe:motivo_status)
                cte:setUpdateEventos(apiCTe:numero_protocolo, apiCTe:data_evento, apiCTe:codigo_status, apiCTe:motivo_status)
            endif
            if !Empty(apiCTe:mensagem)
                cte:setUpdateEventos(apiCTe:numero_protocolo, apiCTe:data_recebimento, apiCTe:codigo_mensagem, apiCTe:mensagem)
            endif

            empresa := appEmpresas:getEmpresa(cte:emp_id)

            // "2019-08-24T14:15:22Z"
            anoEmes := hb_ULeft(getNumbers(apiCTe:data_emissao), 6)
            directory := appData:dfePath + empresa:CNPJ + '\CTe\' + anoEmes + '\'

            if !hb_DirExists(directory)
                hb_DirBuild(directory)
            endif

            if apiCte:BaixarPDFdoDACTE()
                targetFile := apiCTe:chave + '-cte.pdf'
                if hb_MemoWrit(directory + targetFile, apiCTe:pdf_dacte)
                    saveLog("Arquivo PDF do DACTE salvo com sucesso: " + directory + targetFile)
                    cte:setUpdateEventos(apiCTe:numero_protocolo, apiCTe:data_evento, "PDF DACTE", "Arquivo PDF do DACTE salvo com sucesso")
                else
                    saveLog("Erro ao escrever pdf binary em arquivo " + targetFile + " na pasta " + directory)
                    cte:setUpdateEventos(apiCTe:numero_protocolo, apiCTe:data_evento, "PDF DACTE", "Falha ao salvar arquivo PDF do DACTE!")
                endif
            else
                saveLog("Arquivo PDF do DACTE não retornado; CTe Chave: " + apiCTe:chave)
                cte:setUpdateEventos(apiCTe:numero_protocolo, apiCTe:data_evento, "PDF DACTE", "Arquivo PDF do DACTE não foi retornado")
            endif

            if apiCte:BaixarXMLdoCTe()
                targetFile := apiCTe:chave + '-cte.xml'
                if hb_MemoWrit(directory + targetFile, apiCTe:xml_cte)
                    saveLog("Arquivo XML do CTe salvo com sucesso: " + directory + targetFile)
                    // Aqui: Subir o arquivo para o servidor web
                    // uploadXMLdoCTe(directory + targetFile)
                    cte:setUpdateEventos(apiCTe:numero_protocolo, apiCTe:data_evento, "XML CTE", "Arquivo XML do CTe salvo com sucesso")
                else
                    saveLog("Erro ao escrever xml binary em arquivo " + targetFile + " na pasta " + directory)
                    cte:setUpdateEventos(apiCTe:numero_protocolo, apiCTe:data_evento, "XML CTE", "Falha ao salvar arquivo XML do CTe!")
                endif
            else
                saveLog("Arquivo XML do CTe não retornado; CTe Chave: " + apiCTe:chave)
                cte:setUpdateEventos(apiCTe:numero_protocolo, apiCTe:data_evento, "XML CTE", "Arquivo XML do CTe não foi retornado")
            endif
        endif

    endif

    if !emitido
        aError := getMessageApiError(apiCTe, false)
        for each error in aError
            cte:setUpdateEventos("Erro", date_as_DateTime(date(), false, false), error["code"], error["message"])
        next
        cte:setSituacao("ERRO")
        // Debug
        consoleLog("apiCte:response" + apiCTe:response + hb_eol() + "API Conectado: " + iif(apiCTe:connected, "SIM", "NÃO"))
    endif

    cte:setUpdateCte('cte_monitor_action', "EXECUTED")
    cte:save()
    cte:saveEventos()

return
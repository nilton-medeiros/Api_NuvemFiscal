#include "hmg.ch"
#include <hbclass.ch>

class TDbCTes
    data ctes

    method new() constructor
    method count() setget
    method getListCTes()
    method getAnexosCTe(hCTe)
    method getEmails(hCTe)
    method getDocAnteriores(id)
    method getRodoOCC(id)
    method getAereoCub3(id)
    method updateCTe(cId, aFields)
    method insertEventos(hEvent)

end class

method new() class TDbCTes
    ::ctes := {}
return self

method getListCTes() class TDbCTes
    local hCTe, hAnexos, emails, docTransAnt, modalidade
    local dbCTes, empresa, sql := TSQLString():new()

    sql:setValue("SELECT cte_id AS id, ")
    sql:add("emp_id, ")
    sql:add("cte_versao_leiaute_xml AS versao_xml, ")
    sql:add("cte_data_hora_emissao AS dhEmi, ")
    sql:add("cte_modelo AS modelo, ")
    sql:add("cte_serie AS serie, ")
    sql:add("cte_numero AS nCT, ")
    sql:add("cte_minuta AS cCT, ")
    sql:add("cte_situacao AS situacao, ")
    sql:add("cte_chave AS chCTe, ")
    sql:add("cte_protocolo_autorizacao AS nProt, ")
    sql:add("cte_cfop AS CFOP, ")
    sql:add("cte_natureza_operacao AS natOp, ")
    sql:add("cte_forma_emissao AS tpEmis, ")
    sql:add("cte_tipo_do_cte AS tpCTe, ")
    sql:add("cte_modal AS modal, ")
    sql:add("cte_tipo_servico AS tpServ, ")
    sql:add("cid_origem_codigo_municipio AS cMunIni, ")
    sql:add("cid_origem_municipio AS xMunIni, ")
    sql:add("cid_origem_uf AS UFIni, ")
    sql:add("cid_destino_codigo_municipio AS cMunFim, ")
    sql:add("cid_destino_municipio AS xMunFim, ")
    sql:add("cid_destino_uf AS UFFim, ")
    sql:add("cte_retira AS retira, ")
    sql:add("cte_detalhe_retira AS xDetRetira, ")
    sql:add("clie_tomador_id, ")
    sql:add("tom_icms AS indIEToma, ")
    sql:add("tom_ie_isento, ")
    sql:add("cte_tomador AS tomador, ")
    sql:add("tom_cnpj, ")
    sql:add("tom_ie, ")
    sql:add("tom_cpf, ")
    sql:add("tom_nome_fantasia AS tom_xFant, ")
    sql:add("tom_razao_social AS tom_xNome, ")
    sql:add("tom_fone, ")
    sql:add("tom_end_logradouro, ")
    sql:add("tom_end_numero, ")
    sql:add("tom_end_complemento, ")
    sql:add("tom_end_bairro, ")
    sql:add("tom_cid_codigo_municipio, ")
    sql:add("tom_cid_municipio, ")
    sql:add("tom_end_cep, ")
    sql:add("tom_cid_uf, ")
    sql:add("cte_carac_adic_transp AS xCaracAd, ")
    sql:add("cte_carac_adic_servico AS xCaracSer, ")
    sql:add("cte_emissor AS xEmi, ")
    sql:add("cid_origem_sigla AS xOrig, ")
    sql:add("cid_passagem_sigla AS xPass, ")
    sql:add("cid_destino_sigla AS xDest, ")
    sql:add("cte_tp_data_entrega AS tpPer, ")
    sql:add("cte_data_programada AS dProg, ")
    sql:add("cte_data_inicial AS dIni, ")
    sql:add("cte_data_final AS dFim, ")
    sql:add("cte_tp_hora_entrega AS tpHor, ")
    sql:add("cte_hora_programada AS hProg, ")
    sql:add("cte_hora_inicial AS hIni, ")
    sql:add("cte_hora_final AS hFim, ")
    sql:add("cte_obs_gerais AS xObs, ")
    sql:add("clie_remetente_id, ")
    sql:add("rem_razao_social, ")
    sql:add("rem_nome_fantasia, ")
    sql:add("rem_cnpj, ")
    sql:add("rem_ie, ")
    sql:add("rem_cpf, ")
    sql:add("rem_fone, ")
    sql:add("rem_end_logradouro, ")
    sql:add("rem_end_numero, ")
    sql:add("rem_end_complemento, ")
    sql:add("rem_end_bairro, ")
    sql:add("rem_cid_codigo_municipio, ")
    sql:add("rem_cid_municipio, ")
    sql:add("rem_end_cep, ")
    sql:add("rem_cid_uf, ")
    sql:add("rem_icms, ")
    sql:add("clie_destinatario_id, ")
    sql:add("des_razao_social, ")
    sql:add("des_nome_fantasia, ")
    sql:add("des_cnpj, ")
    sql:add("des_ie, ")
    sql:add("des_cpf, ")
    sql:add("des_fone, ")
    sql:add("des_end_logradouro, ")
    sql:add("des_end_numero, ")
    sql:add("des_end_complemento, ")
    sql:add("des_end_bairro, ")
    sql:add("des_cid_codigo_municipio, ")
    sql:add("des_cid_municipio, ")
    sql:add("des_end_cep, ")
    sql:add("des_cid_uf, ")
    sql:add("des_icms, ")
    sql:add("des_inscricao_suframa, ")
    sql:add("clie_expedidor_id, ")
    sql:add("exp_razao_social, ")
    sql:add("exp_nome_fantasia, ")
    sql:add("exp_cnpj, ")
    sql:add("exp_ie, ")
    sql:add("exp_cpf, ")
    sql:add("exp_fone, ")
    sql:add("exp_end_logradouro, ")
    sql:add("exp_end_numero, ")
    sql:add("exp_end_complemento, ")
    sql:add("exp_end_bairro, ")
    sql:add("exp_cid_codigo_municipio, ")
    sql:add("exp_cid_municipio, ")
    sql:add("exp_end_cep, ")
    sql:add("exp_cid_uf, ")
    sql:add("exp_icms, ")
    sql:add("clie_recebedor_id, ")
    sql:add("rec_razao_social, ")
    sql:add("rec_nome_fantasia, ")
    sql:add("rec_cnpj, ")
    sql:add("rec_ie, ")
    sql:add("rec_cpf, ")
    sql:add("rec_fone, ")
    sql:add("rec_end_logradouro, ")
    sql:add("rec_end_numero, ")
    sql:add("rec_end_complemento, ")
    sql:add("rec_end_bairro, ")
    sql:add("rec_cid_codigo_municipio, ")
    sql:add("rec_cid_municipio, ")
    sql:add("rec_end_cep, ")
    sql:add("rec_cid_uf, ")
    sql:add("rec_icms, ")
    sql:add("cte_valor_total AS vTPrest, ")
    sql:add("cte_valor_bc AS vBC, ")
    sql:add("cte_aliquota_icms AS pICMS, ")
    sql:add("cte_valor_icms AS vICMS, ")
    sql:add("cte_perc_reduc_bc AS pRedBC, ")
    sql:add("cte_valor_cred_outorgado AS vCred, ")
    sql:add("cte_codigo_sit_tributaria AS codigo_sit_tributaria, ")
    sql:add("cte_valor_pis AS vPIS, ")
    sql:add("cte_valor_cofins AS vCOFINS, ")
    sql:add("cte_valor_icms + cte_valor_pis + cte_valor_cofins AS vTotTrib, ")
    sql:add("cte_info_fisco AS infAdFisco, ")
    sql:add("cte_valor_carga AS vCarga, ")
    sql:add("produto_predominante_nome AS proPred, ")
    sql:add("gt_id_codigo AS cTar, ")
    sql:add("cte_outras_carac_carga AS xOutCat, ")
    sql:add("cte_peso_bruto AS peso_bruto, ")
    sql:add("cte_peso_cubado AS peso_cubado, ")
    sql:add("cte_peso_bc AS peso_bc, ")
    sql:add("cte_cubagem_m3 AS cubagem_m3, ")
    sql:add("cte_qtde_volumes AS qtde_volumes, ")
    sql:add("cte_tipo_doc_anexo AS tipo_doc_anexo, ")
    sql:add("cte_operacional_master AS nOCA, ")
    sql:add("cte_data_entrega_prevista AS dPrevAereo, ")
    sql:add("referencia_uuid, ")
    sql:add("nuvemfiscal_uuid, ")
    sql:add("cte_monitor_action AS monitor_action ")
    sql:add("FROM view_ctes ")

    if (appEmpresas:count == 1)
        // Apenas uma empresa emitente
        empresa := appEmpresas:empresas[1]
        sql:add("WHERE emp_id = " + hb_ntos(empresa:id))
    else
        // Mais de uma empresa emitente
        sql:add("WHERE emp_id IN (")
        primeiro := true
        for each empresa in appEmpresas:empresas
            if !primeiro
                sql:add(",")
            endif
            sql:add(hb_ntos(empresa:id))
            primeiro := false
        next
        sql:add(")")
    endif

    sql:add(" AND cte_monitor_action IN ('SUBMIT','GETFILES','CANCEL') AND ")
    sql:add("cte_versao_leiaute_xml > 3.00 ")
    sql:add("ORDER BY cte_monitor_action, emp_id, cte_numero")

    ::ctes := {}
    dbCTes := TQuery():new(sql:value)

    if dbCTes:executed
        do while !dbCTes:eof()
            hCTe := convertFieldsDb(dbCTes:GetRow())
            hAnexos := ::getAnexosCTe(hCTe)
            emails := ::getEmails(hCTe)
            if (hb_ntos(hCTe['tpServ']) $ "123")
                docTransAnt := ::getDocAnteriores(hCTe["id"])
            endif
            modalidade := iif(hCTe['modal'] == 1, ::getRodoOCC(hCTe["id"]), ::getAereoCub3(hCTe["id"]))
            AAdd(::ctes, TCTe():new(hCTe, hAnexos, emails, docTransAnt, modalidade))
            dbCTes:Skip()
        enddo
    endif

    dbCTes:Destroy()

return nil

method count() class TDbCTes
return hmg_len(::ctes)

method getAnexosCTe(hCTe) class TDbCTes
    local sql := TSQLString():new(), where := TSQLString():new()
    local obsFisco, compCalc, doc
    local hResult := {"obs_fisco" => {}, "comp_calc" => {}, "doc" => {}}

    sql:setValue("SELECT cte_ocf_titulo AS xCampo, cte_ocf_texto AS xTexto, cte_ocf_interessado AS interessado ")
    sql:add("FROM ctes_obs_contr_fisco ")
    sql:add("WHERE cte_id = " + hb_ntos(hCTe['id'])  + " ")
    sql:add("ORDER BY cte_ocf_interessado, cte_ocf_id ")
    obsFisco := TQuery():new(sql:value)

    if obsFisco:executed
        do while !obsFisco:db:Eof()
            AAdd(hResult['obs_fisco'], convertFieldsDb(obsFisco:db:GetRow()))
            obsFisco:db:Skip()
        enddo
    else
       //MsgDebug(queryObs)
       obsFisco:Destroy()
       turnOFF()
    endif

    sql:setValue("SELECT ")
    sql:add("ccc_titulo AS xNome, ")
    sql:add("ccc_valor AS vComp, ")
    sql:add("ccc_tipo_tarifa AS CL, ")
    sql:add("ccc_valor_tarifa_kg AS vTar ")
    sql:add("FROM ctes_comp_calculo ")
    sql:add("WHERE cte_id = " + hb_ntos(hCTe['id']) + " ")
    sql:add("AND (ccc_exibir_valor_dacte = 1 OR ccc_valor > 0)")
    compCalc := TQuery():new(sql:value)

    if compCalc:executed
        do while !compCalc:db:Eof()
            AAdd(hResult['comp_calc'], convertFieldsDb(compCalc:db:GetRow()))
            compCalc:db:Skip()
        enddo
    else
       //MsgDebug(queryObs)
       compCalc:Destroy()
       turnOFF()
    endif

   // Documentos anexos ao CTe
   sql:setValue("SELECT ")
   where:setValue("WHERE cte_id = " + hb_ntos(hCTe['id']) + " ")

   switch hCTe['tipo_doc_anexo']
      case 1 // 1-Nota Fiscal
         sql:add("cte_doc_modelo AS modelo, ")
         sql:add("cte_doc_serie AS serie, ")
         sql:add("cte_doc_bc_icms AS vBC, ")
         sql:add("cte_doc_valor_icms AS vICMS, ")
         sql:add("cte_doc_bc_icms_st AS vBCST, ")
         sql:add("cte_doc_valor_icms_st AS vST, ")
         sql:add("cte_doc_valor_produtos AS vProd, ")
         sql:add("cte_doc_valor_nota AS vNF, ")
         sql:add("cte_doc_cfop AS nCFOP, ")
         sql:add("cte_doc_peso_total AS nPeso, ") // Continua com mais campos a baixo
         where:add("AND cte_doc_numero IS NOT NULL AND cte_doc_numero != '' ") // WHERE para cada caso
         where:add("AND cte_doc_serie IS NOT NULL ")
//       where:add("AND cte_doc_serie IS NOT NULL AND cte_doc_serie != '' ")                   // série = 0 é considerada '', acaba não entrando neste where
         exit
      case 2 // 2-NFe
         sql:add("cte_doc_chave_nfe AS chave, ") // Continua com mais campos a baixo
         where:add("AND cte_doc_chave_nfe IS NOT NULL AND cte_doc_chave_nfe != '' ")
         exit
      case 3 // 3-Declaração
         sql:add("cte_doc_tipo_doc AS tpDoc, ")
         sql:add("cte_doc_descricao AS descOutros, ")
         sql:add("cte_doc_valor_nota AS vDocFisc, ") // Continua com mais campos a baixo
         where:add("AND cte_doc_tipo_doc IS NOT NULL ")
         exit
   endswitch

   sql:add("cte_doc_numero AS nDoc, ")
   sql:add("cte_doc_pin AS PIN, ")
   sql:add("cte_doc_data_emissao AS dEmi ")
   sql:add("FROM ctes_documentos ")
   sql:add(where:value)
   doc := TQuery():new(sql:value)

   if doc:executed
        do while !doc:db:Eof()
            AAdd(hResult['doc'], convertFieldsDb(doc:db:GetRow()))
            doc:db:Skip()
        enddo
    else
        //MsgDebug(queryObs)
        doc:Destroy()
        turnOFF()
    endif

   obsFisco:Destroy()
   compCalc:Destroy()
   doc:Destroy()

return hResult

method getEmails(hCTe) class TDbCTes
    local sql := TSQLString():new()
    local cliente, contato
    local clientes := { ;
                       {"name" => "tomador", "id" => hb_ntos(hCTe['clie_tomador_id']), "email" => ""},;
                       {"name" => "remetente", "id" => hb_ntos(hCTe['clie_remetente_id']), "email" => ""},;
                       {"name" => "destinatario", "id" => hb_ntos(hCTe['clie_destinatario_id']), "email" => ""},;
                       {"name" => "expedidor", "id" => hb_ntos(hCTe['clie_expedidor_id']), "email" => ""},;
                       {"name" => "recebedor", "id" => hb_ntos(hCTe['clie_recebedor_id']), "email" => ""};
                      }

    for each cliente in clientes
        if !Empty(cliente["id"])
            sql:setValue("SELECT con_email_cte as email FROM clientes_contatos ")
            sql:add("WHERE clie_id = " + cliente["id"] + " AND ")
            sql:add("NOT ISNULL(con_email_cte) AND con_email_cte != '' AND ")
            sql:add("LOCATE('.', con_email_cte, LOCATE('@', con_email_cte)) > 0 ")
            sql:add("LIMIT 1")
            contato := TQuery():new(sql:value)
            if !(contato:count == 0)
                cliente['email'] := contato:FieldGet("email")
            endif
            contato:Destroy()
        endif
    next

return clientes

method getDocAnteriores(id) class TDbCTes
    local s := TSQLString():new("SELECT ")
    local emiDocAnt := {}, emitentes, hEmitente

    s:add("cte_eda_id, ")
    s:add("cte_eda_tipo_doc AS tipoDoc, ")
    s:add("cte_eda_cnpj AS CNPJ, ")
    s:add("cte_eda_cpf AS CPF, ")
    s:add("cte_eda_ie AS IE, ")
    s:add("cte_eda_ie_uf AS UF, ")
    s:add("cte_eda_raz_social_nome AS xNome ")
    s:add("FROM ctes_emitentes_ant ")
    s:add("WHERE cte_id = " + hb_ntos(id) + " ")
    s:add("ORDER BY cte_eda_raz_social_nome")
    emitentes := TQuery():new(s:value)

    if emitentes:executed
        do while !emitentes:eof()
            hEmitente := {=>}
            if (emitentes:FieldGet('tipoDoc') == "CNPJ")
                hEmitente["CNPJ"] := emitentes:FieldGet('CNPJ')
                hEmitente["IE"] := emitentes:FieldGet('IE')
            else
                hEmitente["CPF"] := emitentes:FieldGet('CPF')
            endif

            hEmitente["UF"] := emitentes:FieldGet('UF')
            hEmitente["xNome"] := emitentes:FieldGet('xNome')
            hEmitente["idDocAnt"] := {}

            s:setValue("SELECT ")
            s:add("cte_dta_tpdoc AS tpDoc, ")
            s:add("cte_dta_serie AS serie, ")
            s:add("cte_dta_sub_serie AS subser, ")
            s:add("cte_dta_numero AS nDoc, ")
            s:add("cte_dta_data_emissao AS dEmi, ")
            s:add("cte_dta_chave AS chCTe ")
            s:add("FROM ctes_doc_transp_ant ")
            s:add("WHERE cte_eda_id = " + hb_ntos(emitentes:FieldGet('cte_eda_id'))+ " ")
            s:add("ORDER BY cte_dta_chave, cte_dta_serie, cte_dta_sub_serie, cte_dta_numero")

            docTransAnt := TQuery():new(s:value)
            if docTransAnt:executed
                do while !docTransAnt:eof()
                    if !Empty(docTransAnt:FieldGet('chCTe'))
                        // idDocAntEle
                        AAdd(hEmitente["idDocAnt"], {"chCTe" => docTransAnt:FieldGet('chCTe')})
                    elseif !Empty(docTransAnt:FieldGet('tpDoc'))
                        // idDocAntPap
                        AAdd(hEmitente["idDocAnt"], {"tpDoc" => docTransAnt:FieldGet('tpDoc'), ;
                                        "serie" => docTransAnt:FieldGet('serie'), ;
                                        "subser" => docTransAnt:FieldGet('subser'), ;
                                        "nDoc" => docTransAnt:FieldGet('nDoc'), ;
                                        "dEmi" =>  Transform(DToS(docTransAnt:FieldGet('dEmi')), "@R 9999-99-99") ;
                                       })
                    endif
                    docTransAnt:Skip()
                enddo
            endif
            docTransAnt:Destroy()
            AAdd(emiDocAnt, hEmitente)
            emitentes:Skip()
        enddo
    endif
    emitentes:Destroy()
    hEmitente := nil

return emiDocAnt

// OCC: Ordem de Coleta
method getRodoOCC(id) class TDbCTes
    local occ := {}, s := TSQLString():new("SELECT ")
    local serie, coleta, coletas

    s:add("oca_serie AS serie, ")
    s:add("oca_numero AS nOcc, ")
    s:add("oca_data_emissao AS dEmi, ")
    s:add("oca_cnpj_emitente AS CNPJ, ")
    s:add("oca_inscricao_estadual AS IE, ")
    s:add("oca_uf_ie AS UF ")
    s:add("FROM ctes_rod_coletas ")
    s:add("WHERE cte_id = " + hb_ntos(id) + " ")
    s:add("ORDER BY oca_data_emissao")
    coletas := TQuery():new(s:value)

    if coletas:executed
        do while !coletas:eof()

            if Empty(coletas:FieldGet("serie"))
                serie := ""
            else
                serie := hb_ntos(coletas:FieldGet("serie"))
            endif
            AAdd(occ, { ;
                        "serie" => serie, ;
                        "nOcc" => coletas:FieldGet("nOcc"), ;
                        "dEmi" => Transform(coletas:FieldGet("dEmi"), "@R 9999-99-99"), ;
                        "CNPJ" => coletas:FieldGet("CNPJ"), ;
                        "IE" => coletas:FieldGet("IE"), ;
                        "UF" => coletas:FieldGet("UF") ;
                      })
            coletas:Skip()
        enddo
    endif

    coletas:Destroy()

return occ

method getAereoCub3(id) class TDbCTes
    local s := TSQLString():new("SELECT ")
    local dim, aereo := {=>}

    s:add("cte_dim_cumprimento * 100 AS cumprimento, ")
    s:add("cte_dim_altura * 100 AS altura, ")
    s:add("cte_dim_largura * 100 AS largura, ")
    s:add("cte_dim_cubagem_m3 ")
    s:add("FROM ctes_dimensoes ")
    s:add("WHERE cte_id = " + hb_ntos(id) + " ")
    s:add("ORDER BY cte_dim_cubagem_m3 DESC LIMIT 1")

    dim := TQuery():new(s:value)

    if (dim:count == 1)
        aereo["xDime"] := PadL(dim:FieldGet("cumprimento"), 4, "0") + "X" + PadL(dim:FieldGet("altura"), 4, "0") + "X" + PadL(dim:FieldGet("largura"), 4, "0")
        // aereo["cInfManu"] := {"99 - outro (especificar no campo observações)"}
        aereo["cInfManu"] := {"99"}
    else
        // Debug: Após testes, trocar por saveLog() e não passar o s:value
        consoleLog({"dim:count = ", dim:count, hb_eol(), s:value})
    endif

    dim:Destroy()

return aereo

method updateCTe(cId, aFields) class TDbCTes
    local updated, cte, sql := TSQLString():new()
    local hField, campo, valor, n := 0

    sql:setValue("UPDATE ctes SET ")

    for each hField in aFields
        n++
        if !(n == 1)
            sql:add(", ")
        endif
        campo := hField["key"]
        valor := hField["value"]

        switch ValType(valor)
            case "C"
                valor := string_hb_to_mysql(valor)
                sql:add(campo + " = '" + valor + "'")
                exit
            case "N"
                sql:add(campo + " = " + hb_ntos(valor))
                exit
            case "D"
                sql:add(campo + " = '" + Transform(DToS(valor), "@R 9999-99-99") + "'")
                exit
        endswitch
    next

    sql:add(" WHERE cte_id = " + cId)

    cte := TQuery():new(sql:value)
    updated := cte:executed
    cte:Destroy()
    if !updated
        consoleLog(sql:value)   // Debug
    endif

return updated

method insertEventos(aEvents) class TDbCTes
    local inserted, ctes_eventos, sql := TSQLString():new()
    local hEvent, n := 0, codEvent

    sql:setValue("INSERT INTO ctes_eventos (cte_id, cte_ev_protocolo, cte_ev_data_hora, cte_ev_evento, cte_ev_detalhe) VALUES ")

    for each hEvent in aEvents
        n++
        sql:add(iif((n==1), "(", ", ("))
        sql:add(hEvent["cte_id"] + ", ")
        sql:add("'" + string_hb_to_mysql(hEvent["cte_ev_protocolo"]) + "', ")
        sql:add("'" + hEvent["cte_ev_data_hora"] + "', ")

        codEvent := hEvent["cte_ev_evento"]
        if (ValType(codEvent) == "N")
            codEvent := hb_ntos(codEvent)
        elseif !(ValType(codEvent) == "C")
            codEvent := ""
            consoleLog("Código do Evento não definido para tag cte_ev_evento")
        endif
        sql:add("'" + codEvent + "', ")
        sql:add("'" + string_hb_to_mysql(hEvent["cte_ev_detalhe"]) + "')")
    next
    ctes_eventos := TQuery():new(sql:value)
    inserted := ctes_eventos:executed
    ctes_eventos:Destroy()
    if !inserted
        consoleLog(sql:value)   // Debug
    endif

return inserted
#include "hmg.ch"
#include <hbclass.ch>

class TDbMDFes
    data mdfes

    method new() constructor
    method count() setget
    method getListMDFes()
    method getMunCarregamento(cId)
    method getInfPercurso(cId)
    method getInfContratantes(listContratantes)
    method getVeicTracao(cId)
    method getCondutor(cId)
    method getInfDescarga(cId)
    method getSegMDFe(cId, cMDF)
    method getprodPred(cId)
    method getAutXML(listaCTes)
    method getDoc(clieId)
    method updateMDFe(cId, aFields)
    method insertEventos(hEvent)

end class

method new() class TDbMDFes
    ::mdfes := {}
return self

method count() class TDbMDFes
return hmg_len(::mdfes)

method getListMDFes() class TDbMDFes
    local hMDFe := {=>}, mdfeId, hDbMDFe
    local mdfId, dbMDFes, sql := TSQLString():new()

    sql:setValue("SELECT id, ")
    sql:add("emp_id, ")
    sql:add('tpEmit, ')
    sql:add('`mod` AS modelo, ')
    sql:add('serie, ')
    sql:add('nMDF, ')
    sql:add('cMDF as chMDFe, ')
    sql:add('nProt, ')
    sql:add('dhEmi, ')
    sql:add('tpEmis, ')
    sql:add('verProc, ')
    sql:add('UFIni, ')
    sql:add('UFFim, ')
    sql:add('qCTe, ')
    sql:add('vCarga, ')
    sql:add('cUnid, ')
    sql:add('qCarga, ')
    sql:add('infAdFisco, ')
    sql:add('infCpl, ')
    sql:add('lista_ctes, ')
    sql:add('lista_tomadores, ')
    sql:add('referencia_uuid, ')
    sql:add('nuvemfiscal_uuid, ')
    sql:add('situacao, ')
    sql:add('cte_versao_xml, ')
    sql:add('cte_monitor_action AS monitor_action ')
    sql:add('FROM view_mdfes ')

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

    sql:add(" AND cte_monitor_action IN ('SUBMIT','CANCEL','GETFILES','CLOSE') AND ")
    sql:add("cte_versao_xml > 3.00 ")
    sql:add("ORDER BY monitor_action, emp_id, nMDF")

    ::mdfes := {}
    dbMDFes := TQuery():new(sql:value)

    if dbMDFes:executed
        do while !dbMDFes:eof()
            hDbMDFe := convertFieldsDb(dbMDFes:GetRow())
            hMDFe["hDbMDFe"] := hDbMDFe
            mdfeId := hb_ntos(hDbMDFe["id"])
            hMDFe["carregamento"] := ::getMunCarregamento(mdfeId)
            hMDFe["percursos"] := ::getInfPercurso(mdfeId)
            hMDFe["contratantes"] := ::getInfContratantes(hDbMDFe["lista_tomadores"])
            hMDFe["veicTracao"] := ::getVeicTracao(mdfeId)
            hMDFe["condutor"] := ::getCondutor(mdfeId)
            hMDFe["infDescarga"] := ::getInfDescarga(mdfeId)
            hMDFe["aVerb"] := ::getSegMDFe(mdfeId, PadL(hDbMDFe["nMDF"], 9, "0"))
            hMDFe["prodPred"] := ::getprodPred(mdfeId)
            hMDFe["autXML"] := ::getAutXML(hDbMDFe["lista_ctes"])
            AAdd(::mdfes, TMDFe():new(hMDFe))
            dbMDFes:Skip()
        enddo
    endif

    dbMDFes:Destroy()

return nil

method updateMDFe(cId, aFields) class TDbMDFes
    local updated, mdfe, sql := TSQLString():new("UPDATE mdfes SET ")
    local hField, campo, valor, n := 0

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

    sql:add(" WHERE id = " + cId)

    mdfe := TQuery():new(sql:value)
    updated := mdfe:executed
    mdfe:Destroy()

    if !updated
        consoleLog(sql:value)   // Debug
    endif

return updated

method insertEventos(aEvents) class TDbMDFes
    local inserted, ctes_eventos, sql := TSQLString():new()
    local hEvent, n := 0

    sql:setValue("INSERT INTO mdfes_eventos (mdfe_id, protocolo, data_hora, evento, motivo, detalhe) VALUES ")

    for each hEvent in aEvents
        n++
        sql:add(iif((n==1), "(", ", ("))
        sql:add(hEvent["mdfe_id"] + ", ")
        sql:add("'" + string_hb_to_mysql(hEvent["protocolo"]) + "', ")
        sql:add("'" + hEvent["data_hora"] + "', ")
        sql:add("'" + string_hb_to_mysql(hEvent["evento"]) + "', ")
        sql:add("'" + string_hb_to_mysql(hEvent["motivo"]) + "', ")
        sql:add("'" + string_hb_to_mysql(hEvent["detalhe"]) + "')")
    next
    ctes_eventos := TQuery():new(sql:value)
    inserted := ctes_eventos:executed
    ctes_eventos:Destroy()

    if !inserted
        consoleLog(sql:value)   // Debug
    endif

return inserted

method getMunCarregamento(cId) class TDbMDFes
    local sql := TSQLString():new("SELECT ")
    local carrega, aMunCarrega := {}

    sql:add("t1.cid_origem_codigo_municipio AS cMunCarrega, ")
    sql:add("t1.cid_origem_municipio AS xMunCarrega ")
    sql:add("FROM view_ctes AS t1 ")
    sql:add("INNER JOIN mdfes_ctes AS t2 ON t2.ctes_id = t1.cte_id ")
    sql:add("WHERE t2.mdfe_id=" + cId)
    sql:add(" GROUP BY t1.cid_origem_codigo_municipio, t1.cid_origem_municipio")

    carrega := TQuery():new(sql:value)

    if carrega:executed
        do while !carrega:eof()
            AAdd(aMunCarrega, {"cMunCarrega" => hb_ntos(carrega:FieldGet("cMunCarrega")), "xMunCarrega" => ansi_to_unicode(carrega:FieldGet("xMunCarrega"))})
            carrega:Skip()
        enddo
    endif

    carrega:Destroy()

return aMunCarrega

method getInfPercurso(cId) class TDbMDFes
    local sql := TSQLString():new("SELECT DISTINCT UFPer FROM mdfes_percurso ")
    local percursos, aPercursos := {}

    sql:add("WHERE mdfe_id=" + cId + " AND ")
    sql:add("UFPer IS NOT NULL AND UFPer != '' ")
    sql:add("ORDER BY id")

    percursos := TQuery():new(sql:value)

    if percursos:executed
        do while !percursos:eof()
            AAdd(aPercursos, {"UFPer" => percursos:FieldGet("UFPer")})
            percursos:Skip()
        enddo
    endif

    percursos:Destroy()

return aPercursos

method getInfContratantes(listContratantes) class TDbMDFes
    local sql := "SELECT clie_razao_social AS xNome, "
    local doc, tag, xNome, contratantes, aContratantes := {}

    sql += "clie_cnpj AS CNPJ, "
    sql += "clie_cpf AS CPF "
    sql += "FROM clientes "
    sql += "WHERE clie_id IN (" + listContratantes + ") ORDER BY xNome"

    contratantes := TQuery():new(sql)

    if contratantes:executed
        do while !contratantes:eof()
            xNome := ansi_to_unicode(contratantes:FieldGet("xNome"))
            doc := contratantes:FieldGet("CNPJ")
            if Empty(doc)
                tag := "CPF"
                doc := contratantes:FieldGet("CPF")
            else
                tag := "CNPJ"
            endif
            AAdd(aContratantes, {"xNome" => xNome, tag => doc})
            contratantes:Skip()
        enddo
    endif

    contratantes:Destroy()

return aContratantes

method getVeicTracao(cId) class TDbMDFes
    local sql := TSQLString():new("SELECT ")
    local veic, hVeicTracao := {=>}

    sql:add("IF(t1.veic_trac_id > 0, t4.cInt, t3.cte_rv_codigo_interno) AS cInt, ")
    sql:add("IF(t1.veic_trac_id > 0, t4.placa, t3.cte_rv_placa) AS placa, ")
    sql:add("IF(t1.veic_trac_id > 0, t4.RENAVAM, t3.cte_rv_renavam) AS RENAVAM, ")
    sql:add("IF(t1.veic_trac_id > 0, t4.tara, t3.cte_rv_tara) AS tara, ")
    sql:add("IF(t1.veic_trac_id > 0, t4.capKG, t3.cte_rv_cap_kg) AS capKG, ")
    sql:add("IF(t1.veic_trac_id > 0, t4.capM3, t3.cte_rv_cap_m3) AS capM3, ")
    sql:add("RIGHT(CONCAT('0', IF(t1.veic_trac_id > 0, t4.tpRod, t3.cte_rv_tp_rodado)), 2) AS tpRod, ")
    sql:add("RIGHT(CONCAT('0', IF(t1.veic_trac_id > 0, t4.tpCar, t3.cte_rv_tp_carroceria)), 2) AS tpCar, ")
    sql:add("IF(t1.veic_trac_id > 0, t4.UF, t3.cte_rv_uf_licenciado) AS uf_licenciado, ")
    sql:add("IF(t1.veic_trac_id > 0, IF(t4.agre_id > 0, 'T', 'P'), t3.cte_rv_tp_propriedade) AS tp_propriedade, ")
    sql:add("RIGHT(CONCAT('00000000000000', IF(t1.veic_trac_id > 0, IF(t5.tipo_documento = 'CNPJ', t5.documento, NULL), t3.cte_rv_cnpj)), 14) AS cnpj, ")
    sql:add("RIGHT(CONCAT('00000000000000', IF(t1.veic_trac_id > 0, IF(t5.tipo_documento = 'CPF', t5.documento, NULL), t3.cte_rv_cpf)), 11) AS cpf, ")
    sql:add("IF(t1.veic_trac_id > 0, t5.RNTRC, t3.cte_rv_rntrc) AS RNTRC, ")
    sql:add("IF(t1.veic_trac_id > 0, t5.xNome, t3.cte_rv_razao_social) AS xNome, ")
    sql:add("IF(t1.veic_trac_id > 0, t5.IE, t3.cte_rv_inscricao_estadual) AS IE, ")
    sql:add("IF(t1.veic_trac_id > 0, t5.tpProp, t3.cte_rv_tp_proprietario) AS tpProp ")
    sql:add("FROM mdfes_inf_unid_transp AS t1 ")
    sql:add("LEFT JOIN ctes_rod_motoristas AS t2 ON t2.cte_mo_id = t1.cte_mo_id ")
    sql:add("LEFT JOIN ctes_rod_veiculos AS t3 ON t3.cte_rv_id = t2.cte_rv_id ")
    sql:add("LEFT JOIN veiculos AS t4 ON t4.id = t1.veic_trac_id ")
    sql:add("LEFT JOIN agregados AS t5 ON t5.id = t4.agre_id ")
    sql:add("WHERE t1.mdfe_id = " + cId + " AND ")
    sql:add("(t1.cte_mo_id > 0 OR t1.veic_trac_id > 0) ")
    sql:add("LIMIT 1")

    veic := TQuery():new(sql:value)

    if (veic:count == 1)
        hVeicTracao := convertFieldsDb(veic:GetRow())
    endif

    veic:Destroy()

return hVeicTracao

method getCondutor(cId) class TDbMDFes
    local sql := TSQLString():new("SELECT ")
    local condutores, aCondutores := {}, cpf, xNome

    sql:add("IF(t1.mot_id > 0, t3.cpf, t2.cte_mo_cpf) AS CPF, ")
    sql:add("IF(t1.mot_id > 0, t3.nome, t2.cte_mo_motorista) AS xNome ")
    sql:add("FROM mdfes_inf_unid_transp AS t1 ")
    sql:add("LEFT JOIN ctes_rod_motoristas AS t2 ON t2.cte_mo_id = t1.cte_mo_id ")
    sql:add("LEFT JOIN motoristas AS t3 ON t3.id = t1.mot_id ")
    sql:add("WHERE t1.mdfe_id = " + cId + " AND ")
    sql:add("(t1.cte_mo_id > 0 OR t1.mot_id > 0)")

    condutores := TQuery():new(sql:value)

    if !(condutores:count == 0)
        do while !condutores:eof()
            cpf := PadL(condutores:FieldGet("CPF"), 11, "0")
            xNome := ansi_to_unicode(condutores:FieldGet("xNome"))
            AAdd(aCondutores, {"CPF" => cpf, "xNome" => desacentuar(AllTrim(xNome))})
            condutores:Skip()
        enddo
    endif

    condutores:Destroy()

return aCondutores

method getInfDescarga(cId) class TDbMDFes
    local sql := TSQLString():new("SELECT ")
    local infCarga, aInfCarga := {}, cMunDescarga, xMunDescarga, chCTes, aInfCTe := {}

    sql:add("t1.cid_id_destino AS destino_cid_id, ")
    sql:add("t1.cid_destino_codigo_municipio AS cMunDescarga, ")
    sql:add("t1.cid_destino_municipio AS xMunDescarga ")
    sql:add("FROM view_ctes AS t1 ")
    sql:add("INNER JOIN mdfes_ctes AS t2 ON t2.ctes_id = t1.cte_id ")
    sql:add("WHERE t2.mdfe_id = " + cId + " ")
    sql:add("GROUP BY t1.cid_id_destino")

    infCarga := TQuery():new(sql:value)

    if !(infCarga:count == 0)

        do while !infCarga:eof()

            sql:setValue("SELECT t1.cte_chave AS chCTe FROM ctes AS t1 ")
            sql:add("INNER JOIN mdfes_ctes AS t2 ON t2.ctes_id = t1.cte_id ")
            sql:add("WHERE t2.mdfe_id = " + cId + " AND ")
            sql:add("t1.cid_id_destino = " + hb_ntos(infCarga:FieldGet("destino_cid_id")) + " ")
            sql:add("ORDER BY t1.cte_chave")

            chCTes := TQuery():new(sql:value)

            if !(chCTes:count == 0)
                do while !chCTes:eof()
                    AAdd(aInfCTe, {"chCTe" => chCTes:FieldGet("chCTe")})
                    chCTes:Skip()
                enddo
            endif

            cMunDescarga := infCarga:FieldGet("cMunDescarga")
            xMunDescarga := ansi_to_unicode(infCarga:FieldGet("xMunDescarga"))

            AAdd(aInfCarga, {"cMunDescarga" => hb_ntos(cMunDescarga), "xMunDescarga" => xMunDescarga, "infCTe" => aInfCTe})

            aInfCTe := {}
            chCTes:Destroy()
            infCarga:Skip()

        enddo

    endif

    infCarga:Destroy()

return aInfCarga

method getSegMDFe(cId, cMDF) class TDbMDFes
    local segs, aAver := {}, sql := TSQLString():new("SELECT cte_seg_averbacao AS nAver ")

    sql:add("FROM ctes_seguro ")
    sql:add("WHERE cte_id IN (SELECT ctes_id FROM mdfes_ctes WHERE mdfe_id = " + cId + ") AND ")
    sql:add("NOT ISNULL(cte_seg_averbacao) AND ")
    sql:add("cte_seg_averbacao != '' ")
    sql:add("GROUP BY cte_seg_averbacao")

    segs := TQuery():new(sql:value)

    if (segs:count == 0)
        AAdd(aAver, cMDF)
    else
        do while !segs:eof()
            AAdd(aAver, segs:FieldGet("nAver"))
            segs:Skip()
        enddo
    endif

    segs:Destroy()

return aAver

method getprodPred(cId) class TDbMDFes
    local produto, prodPred := {=>}, sql := TSQLString():new("SELECT ")

    sql:add("pr.prod_produto AS xProd, ")
    sql:add("cl.clie_cep AS destCEP ")
    sql:add("FROM mdfes_ctes AS md ")
    sql:add("INNER JOIN ctes AS ct ON ct.cte_id = md.ctes_id ")
    sql:add("INNER JOIN produtos AS pr ON pr.prod_id = ct.prod_id ")
    sql:add("INNER JOIN clientes AS cl ON cl.clie_id = ct.clie_destinatario_id ")
    sql:add("WHERE md.mdfe_id = " + cId + " LIMIT 1")

    produto := TQuery():new(sql:value)

    if (produto:count == 1)
        prodPred["tpCarga"] := "05"
        prodPred["xProd"] := ansi_to_unicode(produto:FieldGet("xProd"))
        prodPred["cEAN"] := "SEM GTIN"
        prodPred["NCM"] := "00000000"
        prodPred["infLocalCarrega"] := ""
        prodPred["infLocalDescarrega"] := produto:FieldGet("destCEP")
    endif

return prodPred

method getAutXML(listaCTes) class TDbMDFes
    local autorizados, hRow, autXML := {}, sql := TSQLString():new("SELECT ")
    local id, aClieIds := {}, hDoc

    sql:add("clie_remetente_id AS remId, ")
    sql:add("clie_coleta_id AS colId, ")
    sql:add("clie_expedidor_id AS expId, ")
    sql:add("clie_recebedor_id AS recId, ")
    sql:add("clie_destinatario_id AS desId, ")
    sql:add("clie_entrega_id AS entId, ")
    sql:add("clie_tomador_id AS tomId, ")
    sql:add("cte_tomador AS tomador ")
    sql:add("FROM ctes ")
    sql:add("WHERE cte_id IN (" + listaCTes + ")")

    autorizados := TQuery():new(sql:value)

    if !(autorizados:count == 0)

        do while !autorizados:eof()

            hRow := convertFieldsDb(autorizados:GetRow())

            id := hRow["remId"]
            if !Empty(id) .and. (hb_AScan(aClieIds, id) == 0)
                AAdd(aClieIds, id)
                hDoc := ::getDoc(hb_ntos(id))
                if !Empty(hDoc) .and. (hb_AScan(autXML, {|hVal| hb_HGetDef(hVal, "CNPJ", "CPF") == hb_HGetDef(hDoc, "CNPJ", "CPF")}) == 0)
                    AAdd(autXML, hDoc)
                endif
            endif

            id := hRow["colId"]
            if !Empty(id) .and. (hb_AScan(aClieIds, id) == 0)
                AAdd(aClieIds, id)
                hDoc := ::getDoc(hb_ntos(id))
                if !Empty(hDoc) .and. (hb_AScan(autXML, {|hVal| hb_HGetDef(hVal, "CNPJ", "CPF") == hb_HGetDef(hDoc, "CNPJ", "CPF")}) == 0)
                    AAdd(autXML, hDoc)
                endif
            endif

            id := hRow["expId"]
            if !Empty(id) .and. (hb_AScan(aClieIds, id) == 0)
                AAdd(aClieIds, id)
                hDoc := ::getDoc(hb_ntos(id))
                if !Empty(hDoc) .and. (hb_AScan(autXML, {|hVal| hb_HGetDef(hVal, "CNPJ", "CPF") == hb_HGetDef(hDoc, "CNPJ", "CPF")}) == 0)
                    AAdd(autXML, hDoc)
                endif
            endif

            id := hRow["recId"]
            if !Empty(id) .and. (hb_AScan(aClieIds, id) == 0)
                AAdd(aClieIds, id)
                hDoc := ::getDoc(hb_ntos(id))
                if !Empty(hDoc) .and. (hb_AScan(autXML, {|hVal| hb_HGetDef(hVal, "CNPJ", "CPF") == hb_HGetDef(hDoc, "CNPJ", "CPF")}) == 0)
                    AAdd(autXML, hDoc)
                endif
            endif

            id := hRow["desId"]
            if !Empty(id) .and. (hb_AScan(aClieIds, id) == 0)
                AAdd(aClieIds, id)
                hDoc := ::getDoc(hb_ntos(id))
                if !Empty(hDoc) .and. (hb_AScan(autXML, {|hVal| hb_HGetDef(hVal, "CNPJ", "CPF") == hb_HGetDef(hDoc, "CNPJ", "CPF")}) == 0)
                    AAdd(autXML, hDoc)
                endif
            endif

            id := hRow["entId"]
            if !Empty(id) .and. (hb_AScan(aClieIds, id) == 0)
                AAdd(aClieIds, id)
                hDoc := ::getDoc(hb_ntos(id))
                if !Empty(hDoc) .and. (hb_AScan(autXML, {|hVal| hb_HGetDef(hVal, "CNPJ", "CPF") == hb_HGetDef(hDoc, "CNPJ", "CPF")}) == 0)
                    AAdd(autXML, hDoc)
                endif
            endif

            if (hRow["tomador"] == 4)
                id := hRow["tomId"]
                if !Empty(id) .and. (hb_AScan(aClieIds, id) == 0)
                    AAdd(aClieIds, id)
                    hDoc := ::getDoc(hb_ntos(id))
                    if !Empty(hDoc) .and. (hb_AScan(autXML, {|hVal| hb_HGetDef(hVal, "CNPJ", "CPF") == hb_HGetDef(hDoc, "CNPJ", "CPF")}) == 0)
                        AAdd(autXML, hDoc)
                    endif
                endif
            endif

            autorizados:Skip()

        enddo

    endif

    autorizados:Destroy()

return autXML

method getDoc(clieId) class TDbMDFes
    local clie := TQuery():new("SELECT clie_cnpj AS cnpj, clie_cpf as cpf FROM clientes WHERE clie_id=" + clieId)
    local hDoc := {=>}

    if clie:executed .and. !(clie:count == 0)
        if !Empty(clie:FieldGet("cnpj"))
            hDoc["CNPJ"] := clie:FieldGet("cnpj")
        else
            if !Empty(clie:FieldGet("cpf"))
                hDoc["CPF"] := clie:FieldGet("cpf")
            endif
        endif
    endif

    clie:Destroy()

return hDoc
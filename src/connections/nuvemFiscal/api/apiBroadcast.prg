#include "hmg.ch"

/*
    Broadcast: Transmitir
    Transmite à API da Nuvem Fiscal a solicitação (endpoint) e json
    (body) de acordo com o método http solicitado.
*/
function Broadcast(connection, httpMethod, apiUrl, token, operation, body, content_type, accept)
    local objError
    local response := {"error" => false, "status" => 0, "ContentType" => "", "response" => "", "sefazOff" => {=>}}
    local sefazOFF

    begin sequence

        connection:Open(httpMethod, apiUrl, false)
        connection:SetRequestHeader("Authorization", "Bearer " + token)

        if Empty(content_type)
            content_type := ""
        else
            connection:SetRequestHeader("Content-Type", content_type)   // Request Body Schema
        endif
        if !Empty(accept)
            connection:SetRequestHeader("Accept", accept)
        endif

        if Empty(body)
            connection:Send()
        else
            // Request Body
            connection:Send(body)
        endif

        if ("image" $ content_type)
            connection:WaitForResponse(70000)
        else
            connection:WaitForResponse(5000)
        endif

    recover using objError
        if (objError:genCode == 0)
            // consoleLog({"Erro de conexão com o site", hb_eol(), hb_eol(), hb_eol()})
            saveLog({"Erro de conexão com API Nuvem Fiscal em " + operation, hb_eol(), hb_eol(), hb_eol()})
            response["response"] := "Erro de conesão com a API Nuvem Fiscal em " + operation
        else
            // consoleLog({"Erro de conexão com API Nuvem Fiscal", hb_eol(), "Error: ", objError:description, hb_eol(), hb_eol()})
            saveLog({"Erro de conexão com API Nuvem Fiscal em " + operation, hb_eol(), "Error: ", objError:description, hb_eol()})
            response["response"] := "Erro de conesão com a API Nuvem Fiscal em " + operation + " | " + objError:description
        endif
        response["error"] := true
        response["ContentType"] := "text"
        Break
    end sequence

    if response["error"]
        // Debug: Remover esta linha e a debaixo após testes
        if (Lower(Left(operation, 6)) == "baixar")
            consoleLog({"Debug: " + operation + " |ContentType: " + response["ContentType"]})
        else
            consoleLog({"Debug: " + operation + " |ContentType: " + response["ContentType"] + " |Response: ", hb_eol(), response["response"]})
        endif
    else

        response["status"] := connection:Status

        if (response["status"] > 199) .and. (response["status"] < 300)

            // Entre 200 e 299
            if !Empty(connection:ResponseBody)
                response["response"] := connection:ResponseBody
                response["ContentType"] := "json"
            endif

        else    // elseif (response["status"] > 399) .and. (response["status"] < 600)

            if ("json" $ connection:getResponseHeader("Content-Type"))

                // "application/json"
                response["ContentType"] := "json"
                response["response"] := connection:ResponseBody

                sefazOFF := hb_jsonDecode(response["response"])

                if hb_HGetRef(sefazOFF, "status") .and. hb_HGetRef(sefazOFF, "autorizacao")

                    sefazOFF := sefazOFF["autorizacao"]

                    if hb_HGetRef(sefazOFF, "motivo_status") .and. "the server name cannot be resolved" $ Lower(sefazOFF["motivo_status"])
                        response["sefazOff"]["id"] := sefazOFF["id"]
                        response["sefazOff"]["codigo_status"] := sefazOFF["codigo_status"]
                        response["sefazOff"]["motivo_status"] := sefazOFF["motivo_status"]
                    endif

                endif

            else
                // "application/text"
                response["ContentType"] := "text"
                if !Empty(connection:ResponseText)
                    response["response"] := connection:ResponseText
                elseif !Empty(connection:ResponseBody)
                    response["response"] := connection:ResponseBody
                else
                    response["response"] := "ResponseText e ResponseBody retornaram vazio, sem mensagem"
                endif
            endif

            response["error"] := true

        endif

        // Debug: Remover esta linha e a debaixo após testes
        consoleLog({"Debug: " + operation + ;
            " | HTTP Status: ", response["status"], hb_eol(), ;
            "URL API (", httpMethod + "): ", apiUrl, hb_eol(), ;
            "content_type: ", iif(content_type == nil, "NULL", content_type), hb_eol(), ;
            "accept: ", iif(accept == nil, "NULL", accept), hb_eol(), ;
            "Body: ", iif(body == nil, "NULL", iif("image" $ content_type, "[ ARQUIVO BINARIO DA IMAGEM ]", body)), hb_eol(), ;
            "Response: ", iif(response["response"] == nil .or. Empty(response["response"]), "NULL", ;
                          iif((Lower(Left(operation, 6)) == "baixar"), "Response é um ARQUIVO BINÁRIO", response["response"])) ;
        })

    endif

return response

#include "hmg.ch"

/*
    Broadcast: Transmitir
    Transmite à API da Nuvem Fiscal a solicitação (endpoint) e json
    (body) de acordo com o método http solicitado.
*/
function Broadcast(connection, httpMethod, apiUrl, token, operation, body, content_type, accept)
    local objError
    local resposta := {"error" => false, "status" => 0, "ContentType" => "", "response" => ""}

    begin sequence

        connection:Open(httpMethod, apiUrl, false)
        connection:SetRequestHeader("Authorization", "Bearer " + token)

        if !Empty(content_type)
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

        connection:WaitForResponse(5000)

    recover using objError
        if (objError:genCode == 0)
            // consoleLog({"Erro de conexão com o site", hb_eol(), hb_eol(), hb_eol()})
            saveLog({"Erro de conexão com o site em " + operation, hb_eol(), hb_eol(), hb_eol()})
            resposta["response"] := "Erro de conesão com a API Nuvem Fiscal em " + operation
        else
            // consoleLog({"Erro de conexão com o site", hb_eol(), "Error: ", objError:description, hb_eol(), hb_eol()})
            saveLog({"Erro de conexão com o site em " + operation, hb_eol(), "Error: ", objError:description, hb_eol()})
            resposta["response"] := "Erro de conesão com a API Nuvem Fiscal em " + operation + " | " + objError:description
        endif
        resposta["error"] := true
        resposta["ContentType"] := "text"
        Break
    end sequence

    if resposta["error"]
        // Debug: Remover esta linha e a debaixo após testes
        consoleLog({"Debug: " + operation + " |ContentType: " + resposta["ContentType"] + " |Response: ", hb_eol(), resposta["response"]})
    else

         resposta["status"] := connection:Status

        if (resposta["status"] > 199) .and. (resposta["status"] < 300)

            // Entre 200 e 299
            resposta["response"] := connection:ResponseBody
            resposta["ContentType"] := "json"

        else    // if (resposta["status"] > 399) .and. (resposta["status"] < 600)

            resposta["error"] := true

            if ("json" $ connection:getResponseHeader("Content-Type"))
                // "application/json"
                resposta["response"] := connection:ResponseBody
                resposta["ContentType"] := "json"
            else
                // "application/text"
                resposta["response"] := connection:ResponseText
                resposta["ContentType"] := "text"
            endif

        endif

        // Debug: Remover esta linha e a debaixo após testes
        consoleLog({"Debug: " + operation + " | Response: ", hb_eol(), resposta["response"]})
    endif

return resposta

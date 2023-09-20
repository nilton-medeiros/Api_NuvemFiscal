#include "hmg.ch"
// #define false .F. e #define true .T. definidos dentro de hmg.ch por mim, não é o padrão

/*
    Broadcast: Transmitir
    Transmite à API da Nuvem Fiscal a solicitação (endpoint) e json
    (body) de acordo com o método http solicitado.
*/
function Broadcast(connection, httpMethod, apiUrl, token, operation, body)
    local objError
    local resposta := {"error" => false, "status" => 0, "ContentType" => "", "response" => ""}

    begin sequence

        connection:Open(httpMethod, apiUrl, false)  // modo assíncrono = false
        connection:SetRequestHeader("Authorization", "Bearer " + token)
        connection:SetRequestHeader("Content-Type", "application/json")

        if !Empty(body)
            connection:Send(body)
        endif

        connection:WaitForResponse(5000)

    recover using objError
        if objError:genCode != 0
            // consoleLog({"Erro de conexão com o site", hb_eol(), "Error: ", objError:description, hb_eol(), hb_eol()})
            saveLog({"Erro de conexão com o site em " + operation, hb_eol(), "Error: ", objError:description, hb_eol()})
        else
            // consoleLog({"Erro de conexão com o site", hb_eol(), hb_eol(), hb_eol()})
            saveLog({"Erro de conexão com o site em " + operation, hb_eol(), hb_eol(), hb_eol()})
        endif
        resposta["error"] := true
        resposta["ContentType"] := "text"
        resposta["response"] := "Erro de conesão com a API Nuvem Fiscal em " + operation
        Break
    end sequence

    if !resposta["error"]

         resposta["error"] := true
         resposta["status"] := connection:Status

        if (resposta["status"] > 199) .and. (resposta["status"] < 300)

            // Entre 200 e 299
            resposta["response"] := connection:ResponseBody
            resposta["ContentType"] := "json"
            resposta["error"] := false

        else    // if (resposta["status"] > 399) .and. (resposta["status"] < 600)

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

    endif

return resposta

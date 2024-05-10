
module Jira

  def cria_card_jira(token)
    url = "https://nycnog.atlassian.net/rest/api/3/issue?updateHistory=true&applyDefaultValues=false&skipAutoWatch=true"
    headers = {
      'Accept' => 'application/json',
      'content-type' => 'application/json',
      'Authorization' => "Basic #{token}"
    }

    body = {
      "fields": {
        "project": {
          "id": "10000"
        },
        "issuetype": {
          "id": "10005"
        },
        "summary": "Regressivo",
        "reporter": {
          "id": "5e46ef46ab90210c8de0ee8e"
        }
      }
    }

    retorno = HTTParty.post(url, headers: headers, body: body.to_json)
  end

  def consulta_card(idCard, token)
    url = "https://nycnog.atlassian.net/rest/api/3/issue/#{idCard}"
    headers = {
      'Accept' => 'application/json',
      'content-type' => 'application/json',
      'Authorization' => "Basic #{token}"
    }

    HTTParty.get(url, headers: headers)
  end

  def cria_card_jira_filho(token, idPai, idCt, nomeCt, gherking)
    url = "https://nycnog.atlassian.net/rest/api/3/issue?updateHistory=true&applyDefaultValues=false&skipAutoWatch=true"
    headers = {
      'Accept' => 'application/json',
      'content-type' => 'application/json',
      'Authorization' => "Basic #{token}"
    }

    body = {
      "fields": {
        "project": {
          "id": "10000"
        },
        "issuetype": {
          "id": "10003"
        },
        "summary": "#{idCt} | #{nomeCt}",
        "parent": {
          "id": idPai
        },
        "description": {
          "version": 1,
          "type": "doc",
          "content": [
            {
              "type": "paragraph",
              "content": [
                {
                  "type": "text",
                  "text": gherking
                }
              ]
            }
          ]
        },
        "labels": [],
        "reporter": {
          "id": "5e46ef46ab90210c8de0ee8e"
        }
      }
    }

    retorno = HTTParty.post(url, headers: headers, body: body.to_json)
  end

  def marca_card(idCard, referencia, token)
    url = "https://nycnog.atlassian.net/rest/greenhopper/3/xboard/issue/flag/flag"
    headers = {
      'content-type' => 'application/json',
      'Authorization' => "Basic #{token}"
    }

    body = { "issueKeys": [ idCard ], "flag": true,
      "comment": {
          "content": [
              { "type": "paragraph",
                "content": [
                      {  "type": "emoji",
                          "attrs": {
                              "shortName": ":flag_on:",
                              "id": "atlassian-flag_on",
                              "text": ":flag_on:"
                          }
                      },
                      {
                          "type": "text",
                          "text": " Flag added "
                      }
                  ]
              },
              { "type": "paragraph",
                "content": [
                  {
                      "type": "text",
                      "text": "Referencia do erro #{referencia}"
                   }
                ]
              }
          ],
          "type": "doc",
          "version": 1
      },
      "commentProperty": "",
      "commentVisibility": ""
    }

    retorno = HTTParty.post(url, headers: headers, body: body.to_json)
  end

  def atualiza_status(idCard, status, token, referencia='')
    if status == 'PASS'
      #Conclui
      idtransicao = '31'
    elsif status == 'FAIL'
      marca_card(idCard, referencia, token)
      idtransicao = '21'
    else
      #Em andamento
      idtransicao = '21'
    end
    url = "https://nycnog.atlassian.net/rest/api/3/issue/#{idCard}/transitions"
    headers = {
      'Accept' => 'application/json',
      'content-type' => 'application/json',
      'Authorization' => "Basic #{token}"
    }

    body = {
      "transition": {
        "id": idtransicao
      }
    }

    retorno = HTTParty.post(url, headers: headers, body: body.to_json)
  end

  module_function :cria_card_jira
  module_function :cria_card_jira_filho
  module_function :atualiza_status
  module_function :marca_card
  module_function :consulta_card
end

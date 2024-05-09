require 'httparty'
require 'pry'
require 'nokogiri'
require 'json'

module Confluence

  def consulta_base_cts(idPagina, token)
    url = "https://nycnog.atlassian.net/wiki/api/v2/pages/#{idPagina}?body-format=EDITOR"
    headers = {
      'Accept' => 'application/json',
      'Authorization' => "Basic #{token}"
    }

    retorno = HTTParty.get(url, headers: headers)
  end

  def filtra_tabela(retorno)
    texto = retorno['body']['editor']['value']

    doc = Nokogiri::HTML(texto)
    linhas = doc.css('tr')

    tabela = []
    titulos = linhas[0].css('th').map { |th| th.text.strip }

    linhas[1..-1].each do |linha|
      valores = linha.css('td').map { |td| td.text.strip }

      semFormatar = linha.css('td').map { |td| td }
      gherking = semFormatar.last
      gherkingFormatado = Nokogiri::HTML.fragment(gherking).css('p').map(&:text)
      gherkingFormatado = gherkingFormatado.map { |i| i.gsub(',', '\n') }.join("\n")

      valores[-1] = gherkingFormatado
      agrupado = titulos.zip(valores)
      tabela << agrupado.to_h
    end
    tabela
  end

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

  module_function :consulta_base_cts
  module_function :filtra_tabela
  module_function :cria_card_jira
  module_function :cria_card_jira_filho
end


idPagina = ARGV[0]
token = ARGV[1]

retorno = Confluence.consulta_base_cts(idPagina, token)
tabela = Confluence.filtra_tabela(retorno)

retornoJira = Confluence.cria_card_jira(token)
idPai = retornoJira["id"]
tabela.each do |cenario|
  retornoJira = Confluence.cria_card_jira_filho(token, idPai, cenario["Id ct"], cenario["ct"], cenario["gherking"])
end
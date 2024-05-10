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
      gherkingFormatado = Nokogiri::HTML.fragment(gherking).css('p').map(&:text).join("\n")

      valores[-1] = gherkingFormatado
      agrupado = titulos.zip(valores)
      tabela << agrupado.to_h
    end
    tabela
  end

  module_function :consulta_base_cts
  module_function :filtra_tabela

end


# idPagina = ARGV[0]
# token = ARGV[1]

# retorno = Confluence.consulta_base_cts(idPagina, token)
# tabela = Confluence.filtra_tabela(retorno)

# retornoJira = Confluence.cria_card_jira(token)
# idPai = retornoJira["id"]
# tabela.each do |cenario|
#   retornoJira = Confluence.cria_card_jira_filho(token, idPai, cenario["Id ct"], cenario["ct"], cenario["gherking"])
# end
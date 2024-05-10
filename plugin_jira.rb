require 'httparty'
require 'pry'
require 'nokogiri'
require 'json'
require_relative 'confluence.rb'
require_relative 'jira.rb'

class Plugin
  include Confluence
  include Jira

  def cenarios_filtrados(idPagina, token)
    cenarios = consulta_base_cts(idPagina, token)
    filtra_tabela(cenarios)
  end

  def cria_cenarios_board(token, cenarios)
    retornoJira = cria_card_jira(token)
    idPai = retornoJira["id"]
    cenarios.each do |cenario|
      retornoJira = cria_card_jira_filho(token, idPai, cenario["Id ct"], cenario["ct"], cenario["gherking"])
    end
    mensagem = "Foram criados #{cenarios.length} cenários de teste \nno regressivo #{retornoJira['key']}"
    exibe_retorno_criacao(mensagem)
  end

  def exibe_retorno_criacao(mensagem)
    puts "🚀🚀🚀🚀"
    puts mensagem
    puts "🤖🤖🤖🤖"
  end


end


idPagina = ARGV[0]
token = ARGV[1]

plugin = Plugin.new

cenarios = plugin.cenarios_filtrados(idPagina, token)
plugin.cria_cenarios_board(token, cenarios)

# Jira.atualiza_status('TES-107', 'FAIL', token)


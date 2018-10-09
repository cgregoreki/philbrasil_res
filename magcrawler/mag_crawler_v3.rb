# MagCrawler - Magazine Crawler and Indexer for Openjournal.
# author:         Carlos Gregoreki
# date created:   November 30th, 2016
# updated:        December 11th, 2016

# The pourpouse of this script is to gather information from a list of magazines
# (shown below) and index their articles into PhilBrasil. Also, this script, when 
# executed, checks for updates from these magazines and index the new titles into 
# PhilBrasil. 

# The script works as follows:
# 1) visit the page of the magazine
# 2) search for the total of pages that contains issues links
# 3) for each of these pages, retrieve the links of the issues
# 4) for each issue link, go into the issue and get all the articles
# 5) for each of these articles, go inside the url of the article and retrieve 
#    the article information.
# 6) register the article information to the database.

# =========================
# IMPORTANT: this script does not yet search for updates in pages. 
# The schema once built for this pourpose wasn't good enough. Then, 
# later on, this feature needs to be redesigned and rewritten.
# =========================

# List of magazines:
# Magazine        |        URL
# ------------------------------------------------------------------------------------------------
# Archai          |   http://periodicos.unb.br/index.php/archai/issue/archive
# DoisPontos      |   http://revistas.ufpr.br/doispontos/issue/archive
# Ethic@          |   https://periodicos.ufsc.br/index.php/ethic/issue/archive
# Kriterion       |   http://www.scielo.br/scielo.php?script=sci_issues&pid=0100-512X&lng=pt&nrm=iso
# Manuscrito      |   http://www.scielo.br/scielo.php?script=sci_issues&pid=0100-6045&lng=en&nrm=iso
# Natureza Humana |   http://pepsic.bvsalud.org/scielo.php?script=sci_issues&pid=1517-2430&lng=pt&nrm=iso
# Principia       |   https://periodicos.ufsc.br/index.php/principia/issue/archive
# Principios      |   https://periodicos.ufrn.br/principios/issue/archive
# Scientiae Studia|   http://www.revistas.usp.br/ss/issue/archive
# Studia Kantiana |   http://www.sociedadekant.org/studiakantiana/index.php/sk/issue/archive
# Veritas         |   http://revistaseletronicas.pucrs.br/ojs/index.php/veritas/issue/archive
# Unisinos        |   http://revistas.unisinos.br/index.php/filosofia/issue/archive
# Itaca           |   https://revistas.ufrj.br/index.php/Itaca/issue/archive


# libraries
require 'nokogiri'
require 'open-uri'
require 'open_uri_redirections'
require 'openssl'
require 'colorize'

# ignore security. whatever.
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE


# =================================== #
# GLOBAL VARIABLES #

# list of urls to search for articles:
$magazines_urls = {
   "Archai" => "http://periodicos.unb.br/index.php/archai/issue/archive",
   "DoisPontos" => "http://revistas.ufpr.br/doispontos/issue/archive",
   "ethic@" => "https://periodicos.ufsc.br/index.php/ethic/issue/archive",
   "Kriterion" => "http://www.scielo.br/scielo.php?script=sci_issues&pid=0100-512X&lng=pt&nrm=iso",
   "Manuscrito" => "http://www.scielo.br/scielo.php?script=sci_issues&pid=0100-6045&lng=en&nrm=iso",
   "Natureza Humana" => "http://pepsic.bvsalud.org/scielo.php?script=sci_issues&pid=1517-2430&lng=pt&nrm=iso",
   "Principia" => "https://periodicos.ufsc.br/index.php/principia/issue/archive",
   "Principios" => "https://periodicos.ufrn.br/principios/issue/archive",
   "Scientiae Studia" => "http://www.revistas.usp.br/ss/issue/archive",
   "Studia Kantiana" => "http://www.sociedadekant.org/studiakantiana/index.php/sk/issue/archive",
   "Veritas" => "http://revistaseletronicas.pucrs.br/ojs/index.php/veritas/issue/archive",
   "Unisinos" => "http://revistas.unisinos.br/index.php/filosofia/issue/archive",
   "Itaca" => "https://revistas.ufrj.br/index.php/Itaca/issue/archive"
   }

# Time for logging.
$time_for_error_log = Time.now

$authors = ["Carlos Gregoreki"]
$version_info = {version: 3, date: "2016-12-11 (yyyy-mm-dd)"}

# END - GLOBAL VARIABLES 
# =================================== #


# ========================================= #
# General Functions
# ========================================= #

# logo print function. always sleep 0.2 secs for animation
# effect.
def print_logo()
   sleep(0.2)
   line = "===================================================\n"
   text = [" _____   _      _  _  ____                    _  _ ", "|  __ \\ | |    (_)| ||  _ \\                  (_)| |", "| |__) || |__   _ | || |_) | _ __  __ _  ___  _ | |", "|  ___/ | '_ \\ | || ||  _ < | '__|/ _` |/ __|| || |", "| |     | | | || || || |_) || |  | (_| |\\__ \\| || |", "|_|     |_| |_||_||_||____/ |_|   \\__,_||___/|_||_|"]
   print line
   text.each do |t|
      sleep(0.2)
      puts t
   end
   sleep(0.2)
   print "\n"
   sleep(0.2)
   print line
   sleep(0.2)
end


# print version info of this script
def print_version_info()
   puts "Versão: " + $version_info[:version].to_s + " " + $version_info[:date].to_s
   puts "-----"
end

# print author info
def print_author_info()
   puts "Autor(es): "
   $authors.each do |author|
      puts author
   end
   puts "-----"
end

def print_all_magazines_info()
   puts "Revistas cobertas por este script: "
   $magazines_urls.each do |title, url|
      puts "  " + title
   end
end

def get_break_option()
   option = ""
   while !(option.chomp.casecmp("Y") == 0) and !(option.chomp.casecmp("N") == 0) do
      print "Deseja interromper script em caso de avisos e intervalos entre revistas? (Y/N): "
      option = gets
   end
   
   if option.chomp.casecmp("y") == 0
      puts "Resposta: Sim."
      return true
   elsif !option.chomp.casecmp("n") == 0
      puts "Resposta: Não."
      return false
   end
end

def get_choose_specific_magazine_option()
   option = ""
   while !(option.chomp.casecmp("Y") == 0) and !(option.chomp.casecmp("N") == 0) do
      print "Deseja escolher uma revista específica? (Y/N): "
      option = gets
   end
   
   if option.chomp.casecmp("y") == 0
      puts "Resposta: Sim."
      return true
   elsif !option.chomp.casecmp("n") == 0
      puts "Resposta: Não."
      return false
   end
end

def print_magazine_choices()
   counter = 1
   puts "-----"
   puts "Lista de Revistas: "
   $magazines_urls.each do |name, link|
      puts counter.to_s + ") " + name.to_s
      counter = counter + 1
   end
end

def get_magazine_number(option)
   mag_number = "0"
   if option then
      print_magazine_choices()
      while Integer(mag_number) < 1 or Integer(mag_number) > $magazines_urls.length do
         puts "Escolha uma opção: "
         mag_number = gets 
         mag_number = mag_number.chomp
      end
      return Integer(mag_number)
   else
      return -1
   end
end

def select_magazine_info(mag_number)
   return $magazines_urls.keys[mag_number], $magazines_urls.values[mag_number]
end

def print_article_info(article)
   puts "-----"
   puts "Artigo:"
   print "  Titulo: ", article.title,  "\n"
   print "  Autor:  ", article.author, "\n"
end

def show_magazine_info(mag_name)
   puts "-----"
   puts "Revista: " + mag_name.red
end
# END - General Functions
# ========================================= #

# ========================================= #
# HTML CRAWLER/PARSER FUNCTIONS
# ========================================= #

def get_mag_index_pages(mag_url)
   links = []
   doc = Nokogiri::HTML(open(mag_url, :allow_redirections => :safe))  
   doc.css("a[href]").each do |p|
      if p.attribute('href').to_s.include? "#issues"
         links.push(p.attribute('href').to_s)
      end
   end
   # the link of the actual url is not in the array. it needs to be,
   # since this is the first page that index issues.
   links.push(mag_url)
   return links.uniq
end

def get_edition_urls(url)
   links = []
   doc = Nokogiri::HTML(open(url, :allow_redirections => :safe))  
   doc.css("a[href]").each do |p|
      if p.attribute('href').to_s.include? "/issue/view"
         links.push(p.attribute('href').to_s)
      end
   end

   # length is bad number. Then try scielo procedure.
   if links.uniq.length < 1 then
      doc.css("a[href]").each do |p|
         if p.attribute('href').to_s.include? "sci_issuetoc" then
            links.push(p.attribute('href').to_s)
         end
      end
      puts "Quantidade de edições: " + links.uniq.length.to_s
      return links.uniq, true
   end

   puts "Quantidade de edições: " + links.uniq.length.to_s
   return links.uniq, false
end

def get_articles_links_from_edition_url(url, is_scielo)
   links = []
   doc = Nokogiri::HTML(open(url, :allow_redirections => :safe))  
   if !is_scielo then
      t_titles = doc.css('.tocArticle').css('.tocTitle')
      t_pdfs = doc.css('.tocArticle').css('.tocGalleys')

      tuple = t_titles.zip t_pdfs
      
      tuple.each do |title, pdf|
         titulo = ""
         link = ""
         if title.css('a').length == 1 then
            #it has a title. It's an article.
            titulo = title.css('a')[0].text.strip
            link = (title.css('a[href]')[0])['href']
         elsif title.css('a').length == 0 then
            titulo = title.text.strip
            link = pdf.css('a[href]')[0]['href']
         end

         links.push(link)

      end

      return links
   else
      # scielo part.
      doc.css("a[href]").each do |p|
         if p.text.include? "text in" or  p.text.include? "texto em" then
            links.push(p.attribute('href').to_s)
         end
      end
      return links
   end
end

def get_article_data_from_article_url(url)
   doc = Nokogiri::HTML(open(url, :allow_redirections => :safe))  
   data = Hash.new
   doc.css('meta').each do |p|
      case p.attribute('name').to_s
         when 'DC.Creator.PersonalName',  'citation_author'
            data['author'] = p.attribute('content').to_s
         when 'DC.Description'
            #data['abstract'] = p.attribute('content').to_s
         when 'DC.Identifier.URI', 'citation_fulltext_html_url'
            data['link'] = p.attribute('content').to_s
         when 'DC.Source', 'citation_journal_title'
            data['magazine'] = p.attribute('content').to_s
         when 'DC.Source.Volume', 'citation_volume'
            data['vol_number'] = p.attribute('content').to_s.to_i
         when 'DC.Title', 'citation_title'
            data['title'] = p.attribute('content').to_s
         when 'DC.Type'
            if p.attribute('content').to_s.eql? "Text.Serial.Journal" then
               data['article_type'] = 0 
            end
         when 'DC.Identifier.pageNumber'
            #data['page_number'] = p.attribute('content').to_s
         when 'DC.Source.Issue', 'citation_issue'
            data['issue'] = p.attribute('content').to_s
         when 'citation_author_institution'
            #data['institution'] = p.attribute('content').to_s
         when 'citation_firstpage'
            data['first_page'] = p.attribute('content').to_s
         when 'citation_lastpage'
            data['last_page'] = p.attribute('content').to_s
         when 'DC.Date.issued', 'citation_date'
            date_splitted = p.attribute('content').to_s.split('-')
            year = date_splitted[0]
            month = date_splitted[1]
            day = date_splitted[2]
            data['year'] = year.to_i
         when 'keywords'
            data['keywords'] = p.attribute('content').to_s
         when 'DC.Type.articleType'
            data['article_personal_type'] = p.attribute('content').to_s
      end
   end
   return data
end
# END HTML CRAWLER/PARSER FUNCTIONS
# ========================================= #


# ========================================= #
# DATABASE FUNCTIONS 
# ========================================= #
def save_article_object_to_db(article)
   
   if article.title == nil or article.author == nil then
      raise "ARTICLE_NIL_REQUIRED_VALUE_ERROR"
   end

   if article.title.include? "for Authors" or article.title.include? "aos autores" then
      raise "FORBIDDEN_ARTICLE_TITLE_ERROR"
   end

   if Article.where(title: article.title).length > 0 then
      raise "ARTICLE_ALREADY_IN_DB_ERROR"
   end 

   print "Salvando no banco de dados... ".cyan
   article.save
   print "OK.\n".green
end

# END - DATABASE FUNCTIONS
# ========================================= #

# ========================================= #
# ERROR HANDLING FUNCTIONS
# ========================================= #
def chew_error_and_print_message(e)
   case e.message
      when 'ARTICLE_NIL_REQUIRED_VALUE_ERROR'
         puts "Artigo com título ou autor nulos.".yellow
         # log_article_error_to_file(article, a_link)
         # interrupt(interrupt_option)
      when "ARTICLE_ALREADY_IN_DB_ERROR"
         puts "Artigo já está no Banco de Dados.".green
         # log_article_error_to_file(article, a_link)
      when "FORBIDDEN_ARTICLE_TITLE_ERROR"
         puts "Artigo com título proibido.".yellow
         # interrupt(interrupt_option)
         # log_article_error_to_file(article, a_link)
      else
         puts e.message
   end
   puts "Ignorando artigo com problemas... OK\n"
end


# END - ERROR HANDLING FUNCTIONS
# ========================================= #


# ========================================= #
# MAIN FUNCTION
# ========================================= #
def main()
   print_logo()
   print_author_info()  
   print_version_info()
   print_all_magazines_info()
   break_option = get_break_option()
   choose_specific_magazine_option = get_choose_specific_magazine_option()
   magazine_number = get_magazine_number(choose_specific_magazine_option)

   magazines_to_crawl = Hash.new

   if choose_specific_magazine_option and magazine_number > 0 then
      print "Iniciando procedimento para UMA REVISTA ESPECÍFICA... "
      selected_magazine_name, select_magazine_url = select_magazine_info(magazine_number - 1)
      magazines_to_crawl[selected_magazine_name] = select_magazine_url
      print "OK.\n".green
   else   
      print "Iniciando procedimento para TODAS AS REVISTAS... "
      magazines_to_crawl = $magazines_urls
      print "OK.\n".green
   end

   magazines_to_crawl.each do |mag_name, mag_url|
      show_magazine_info(mag_name)
      mag_index_pages = get_mag_index_pages(mag_url)
      puts "Total de páginas com edições: " + mag_index_pages.length.to_s.blue
      mag_index_pages.each_with_index do |index_url, i|
         puts "=+=+=+=+=", "Interpretando página " + (i+1).to_s.light_blue
         # the function has scielo treatment
         edition_urls, is_scielo = get_edition_urls(index_url)
         edition_urls.each_with_index do |ed_url, index|
            puts "-*-*-*-*-"
            puts "Interpretando " + ((index+1).to_s + "ª").blue + " edição..." 
            articles_urls_list = get_articles_links_from_edition_url(ed_url, is_scielo)
            # there's an intermediate page. Try to put '/showToc' in url
            # and execute again
            if articles_urls_list.length < 1 then
               ed_url = ed_url + "/showToc"
               articles_urls_list = get_articles_links_from_edition_url(ed_url, is_scielo)
            end
            articles_urls_list.each do |a_url|
               article_data = get_article_data_from_article_url(a_url)
               article_object = Article.new(article_data)
               print_article_info(article_object)
               begin
                  save_article_object_to_db(article_object)
               rescue => e
                  chew_error_and_print_message(e)
               end
            end 
         end
      end
   end
   puts "Fim " +  ";".blue + ")".red
   puts "========================"
end

# END - MAIN FUNCTION
# ========================================= #


# ========================================= #
# EXECUTE EVERYTHING
# ========================================= #
main()

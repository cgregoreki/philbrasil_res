# MagCrawler - Magazine Crawler and Indexer for Openjournal.
# author:         Carlos Gregoreki
# date created:   November 30th, 2016

# The pourpouse of this script is to gather information from a list of magazines
# (shown below) and index their articles into PhilBrasil. Also, this script, when 
# executed, checks for updates from these magazines and index the new titles into 
# PhilBrasil. 

# The script works as follows:
# 1) visit the page of the magazine
# 2) search for the total of pages that contains issues links
# 3) for each of these pages, retrieve the links of the issues
# 4) for each issue link, got into the issue and get all the articles
# 5) for each of these articles, go inside the url of the article and retrieve 
#    the article information.
# 6) register the article information to the database.

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


# libraries
require 'nokogiri'
require 'open-uri'
require 'open_uri_redirections'
require 'openssl'
require 'colorize'

# ignore security.
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE


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
   "Veritas" => "http://revistaseletronicas.pucrs.br/ojs/index.php/veritas/issue/archive"
   }

$articles_with_problems = []
$time_for_error_log = Time.now
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


# print upper asteriscs triangle for
# text separation
def print_upper_asteriscs()
   3.downto(1).each do |i|
      i.downto(1).each do |j|
         print "*" 
      end
      print "\n"
   end
end


# print lower asteriscs triangle for
# text separation
def print_lower_asteriscs()
   1.upto(3).each do |i|
      1.upto(i).each do |j|
         print "*" 
      end
      print "\n"
   end
end

# print initial information of this crawler. 
# nothing more than vanity.
def print_initial_info()
   print_upper_asteriscs
   puts "Iniciando MagCrawler para OpenJournal - (para o PhilBrasil)"
   print_lower_asteriscs
end


# print the name of magazines which will be searched.
def print_magazines_urls_info()
   puts "   Lista de revistas a serem atualizadas:"
   $magazines_urls.each do |k,v|
      puts "      " + k.to_s
   end
   puts "   Total de revistas: " + $magazines_urls.length.to_s
   puts "********************"
end


# interrupts the execution
def interrupt(option)
   if option.chomp.eql? "Y" then
      print "Pressione ENTER para continuar: "
      gets
      print "OK. Continuando...\n"
   end
end

# function that gets all the pages that contains issues.
# there are magazines that organize issues in pages, so you need
# to click the number of the page to see more issues. 
# this function gets this information and return the links.
def get_all_index_pages(url)
   links = []
   doc = Nokogiri::HTML(open(url, :allow_redirections => :safe))  
   doc.css("a[href]").each do |p|
      if p.attribute('href').to_s.include? "#issues"
         links.push(p.attribute('href').to_s)
      end
   end
   # the link of the actual url is not in the array. it needs to be,
   # since this is the first page that index issues.
   links.push(url)
   return links.uniq
end


def get_titles_links_from_summary_url(url)

   titles_links = Hash.new
   doc = Nokogiri::HTML(open(url, :allow_redirections => :safe))  
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

      titles_links[titulo] = link

   end

   return titles_links

end

# this function goes inside a article url and retrieve it's information
# and returns it as a Hash
def get_data_for_article_from_url(url)
   doc = Nokogiri::HTML(open(url, :allow_redirections => :safe))  
   data = Hash.new
   doc.css('meta').each do |p|
      case p.attribute('name').to_s
         when 'DC.Creator.PersonalName'
            data['author'] = p.attribute('content').to_s
         when 'DC.Description'
            #data['abstract'] = p.attribute('content').to_s
         when 'DC.Identifier.URI'
            data['link'] = p.attribute('content').to_s
         when 'DC.Source'
            data['magazine'] = p.attribute('content').to_s
         when 'DC.Source.Volume'
            data['vol_number'] = p.attribute('content').to_s.to_i
         when 'DC.Title'
            data['title'] = p.attribute('content').to_s
         when 'DC.Type'
            if p.attribute('content').to_s.eql? "Text.Serial.Journal" then
               data['article_type'] = 0 
            end
         when 'DC.Identifier.pageNumber'
            #data['page_number'] = p.attribute('content').to_s
         when 'DC.Source.Issue'
            data['issue'] = p.attribute('content').to_s
         when 'citation_author_institution'
            #data['institution'] = p.attribute('content').to_s
         when 'citation_firstpage'
            data['first_page'] = p.attribute('content').to_s
         when 'citation_lastpage'
            data['last_page'] = p.attribute('content').to_s
         when 'DC.Date.issued'
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
   data
end


# save the article to the database, verifying if it's inside the database.
def save_article_to_db(article)

   if article.title == nil or article.author == nil then
      raise "ARTICLE_NIL_REQUIRED_VALUE_ERROR"
   end

   if article.title.include? "for Authors" or article.title.include? "aos autores" then
      raise "FORBIDDEN_ARTICLE_TITLE_ERROR"
   end

   if Article.where(title: article.title).length > 0 then
      raise "ARTICLE_ALREADY_IN_DB_ERROR"
   end 

   article.save

end


def get_all_editions_links(url)
   links = []
   doc = Nokogiri::HTML(open(url, :allow_redirections => :safe))  
   doc.css("a[href]").each do |p|
      if p.attribute('href').to_s.include? "/issue/view"
         links.push(p.attribute('href').to_s)
      end
   end
   return links.uniq
end


# print article information to user for more interactiveness.
def print_article_details(article, url, option)
   begin
      print "\tAutor: "+ article.author + "\n"
      print "\tTítulo: "+ article.title + "\n"
   rescue
      puts 'Alguma coisa deu errada com o parser. Talvez um link inválido?'
      puts 'Visite ' + url + ' e verifique!'
      if option.eql? "Y" then
         puts "Pressione ENTER para continuar..."
         gets
      end
      raise 'An error has ocurred.'
   end
end


def nil_to_string(s)
   if s == nil then
      return "NULL"
   else
      return s.to_s
   end
end

def log_article_error_to_file(article, link)
   log_filename = "articles_error" + $time_for_error_log.to_s + ".log"
   open(log_filename, 'a') do |f|
      f.puts "**************"
      f.puts "Título:         " + nil_to_string(article.title)
      f.puts "Autor:          " + nil_to_string(article.author)
      f.puts "Ano:            " + nil_to_string(article.year)
      f.puts "Revista:        " + nil_to_string(article.magazine)
      f.puts "Número:         " + nil_to_string(article.issue)
      f.puts "Volume:         " + nil_to_string(article.vol_number)
      f.puts "Tradutor:       " + nil_to_string(article.translator)
      f.puts "Link:           " + nil_to_string(article.link)
      f.puts "Páginas:        " + nil_to_string(article.first_page)+ " - " + nil_to_string(article.last_page)
      f.puts "Link executado: " + link
   end
end


# the script main function. this starts everything.
def main()
   print_logo

   magazine_number = -1
   puts "Deseja interromper script em caso de avisos e intervalos entre revistas? (Y/N)"
   interrupt_option = gets
   while !(interrupt_option.chomp.eql? "Y") and !(interrupt_option.chomp.eql? "N") do
      puts "Opção inválida!"
      puts "Deseja interromper script em caso de avisos e intervalos entre revistas? (Y/N)"
      interrupt_option = gets
   end

   puts "Deseja escolher uma revista em específica? (Y/N)"
   choice_magazine = gets
   while !(choice_magazine.chomp.eql? "Y") and !(choice_magazine.chomp.eql? "N") do
      puts "Opção inválida!"
      puts "Deseja escolher uma revista em específica? (Y/N)"
      choice_magazine = gets
   end

   if choice_magazine.chomp.eql? "Y" then
      puts "Digite a opcão da revista: "
      magazine_option = 1

      $magazines_urls.keys.each do |k|
         puts magazine_option.to_s + ") " + k
         magazine_option = magazine_option + 1
      end

      magazine_number = gets
      while !(magazine_number.chomp.to_i > 0 ) and !(magazine_number.chomp.to_i < $magazines_urls.length) do
         puts "Opção inválida!"
         puts "Digite a opcão da revista: "
         magazine_number = gets
      end
   end

   interrupt(interrupt_option)
   print_initial_info
   print_magazines_urls_info
   interrupt(interrupt_option)
   
   # for each magazine and its url, visit the url and check for updates, and index the
   # issues that are not indexed.
   if choice_magazine.chomp.to_s.eql? "Y" then
      key =  $magazines_urls.keys[magazine_number.chomp.to_i - 1]
      value = $magazines_urls[key]
      $magazines_urls = Hash.new()
      $magazines_urls[key] = value
   end

   $magazines_urls.each do |k, v|
      print_upper_asteriscs
      puts "Iniciando processamento da revista: " + k.to_s
      index_pages = get_all_index_pages(v)
      puts "Número de páginas que contém as edições: " + index_pages.length.to_s

      # now, for each one of the pages, get the issues on these pages and search
      # for the articles.
      counter = 1
      index_pages.each do |l|
         puts "    Recuperando links das edições da página: " + counter.to_s
         counter = counter + 1
         edition_links = get_all_editions_links(l)
         puts "    Quantidade de edições encontradas: " + edition_links.length.to_s

         # for each of the titles (editions), go inside them and retrieve information
         # about the articles.
         edition_links.each do |edition|
            print "       Recuperando links de artigos... "
            article_links = get_titles_links_from_summary_url(edition)
            if article_links.length < 1 then
               edition = edition + '/showToc'
               article_links = get_titles_links_from_summary_url(edition)
            end
            print "OK.\n"
            puts "        Quantidade de links de artigos: " + article_links.length.to_s

            counter_artigo = 1
            article_links.each do |a_title, a_link|
               print "            Recuperando dados do artigo: " + counter_artigo.to_s + " ..."
               counter_artigo = counter_artigo + 1
               article_data = get_data_for_article_from_url(a_link)
               print "OK.\n"
               print "            Criando objeto artigo... "
               article = Article.new(article_data)
               print "OK.\n"

               begin
                  save_article_to_db(article)
               rescue => e
                  case e.message
                     when 'ARTICLE_NIL_REQUIRED_VALUE_ERROR'
                        puts "        Artigo com título ou autor nulos.".yellow
                        log_article_error_to_file(article, a_link)
                        interrupt(interrupt_option)
                     when "ARTICLE_ALREADY_IN_DB_ERROR"
                        puts "        Artigo já está no Banco de Dados.".green
                        # log_article_error_to_file(article, a_link)
                     when "FORBIDDEN_ARTICLE_TITLE_ERROR"
                        puts "        Artigo com título proibido.".yellow
                        interrupt(interrupt_option)
                        log_article_error_to_file(article, a_link)
                  end
                  puts "              Ignorando artigo com problemas... OK\n"
                  
               end

            
            end
         end
      end
   end
end

# execute the main function.
main()
puts "FIM."

require 'nokogiri'
require 'open-uri'

# gem install progress_bar

# this gem is require. Install from url:
# https://github.com/genki/ruby-terminfo
require 'terminfo'

require 'open_uri_redirections'

require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE


def print_logo()
	# if TermInfo.screen_size[1] > " _____   _      _  _  ____                    _  _ ".length then
		line = "===================================================\n"
		text = " _____   _      _  _  ____                    _  _ \n|  __ \\ | |    (_)| ||  _ \\                  (_)| |\n| |__) || |__   _ | || |_) | _ __  __ _  ___  _ | |\n|  ___/ | '_ \\ | || ||  _ < | '__|/ _` |/ __|| || |\n| |     | | | || || || |_) || |  | (_| |\\__ \\| || |\n|_|     |_| |_||_||_||____/ |_|   \\__,_||___/|_||_|\n"
		print line
		print text
		print "\n"
		print line
	# else
		# print "PhilBrasil\n"
	# end

end

def full_asteriscs()
	columns = TermInfo.screen_size[1]
	
	1.upto(columns) do |i|
		print '*'
	end
	print "\n"
end

def full_dots()
	columns = TermInfo.screen_size[1]
	
	1.upto(columns) do |i|
		print '.'
	end
	print "\n"
end	

def center_text(text)
	length = TermInfo.screen_size[1]
	# if text.length % 2 == 0 then
		# if length % 2 == 0 then
			1.upto(length/2 - text.length/2) do
				print " "
			end
			print text + "\n"
		# end

	# end

end


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
			#tem um link. É um titulo com link
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

def print_article_details(article, url)
	begin
		print "\tAutor: "+ article.author + "\n"
		print "\tTítulo: "+ article.title + "\n"
	rescue
		puts 'Alguma coisa deu errada com o parser. Talvez um link inválido?'
		puts 'Visite ' + url + ' e verifique!'
		raise 'An error has ocurred.'
	end
end


def save_article_to_db(article, url)
	begin
		print_article_details(article, url)
		input = "Y"
		
		if article.title.include? "for Authors" or article.title.include? "aos autores" then
			raise 'An error has ocurred.'
		end

		if Article.where(title: article.title).length > 0 then
			puts 'Artigo já está na base de dados.'
			raise 'Artigo já está na base de dados.'
		end

		while input.to_s != "Y" and input.to_s and "y" and input.to_s != "N" and input.to_s != "n" do
			print "Deseja salvar este artigo? (Y/N): "
			input = gets
			input = input.chomp
		end

		if input == "Y" or input == "y" then
			print "Salvando artigo... "
			article.save
			print "OK.\n"
		elsif input == "N" or input == "n" then
			puts "Ignorando artigo... OK"
		end
	rescue
		puts "Ignorando artigo com problemas... OK"
	end
	
end

def check_for_insertion(article)
	forbidden = ["Páginas Iniciais", "Editorial"]
	
	if forbidden.include? article.article_personal_type then
		return true
	end

	return false
end

def main()
	# full_asteriscs
	print_logo
	# full_asteriscs
	# center_text("Iniciando MagCrawler! No version control =)")
	# center_text("...")
	# full_dots

	puts "Iniciando MagCrawler (for openjournal)! No version control =)"
	puts "..."
	puts "Digite/cole a url da revista (seção anteriores, onde têm todas as revistas):"
	url = gets
	url = url.chomp

	print "Recuperando informações e links das edições... "
	links = get_all_editions_links(url)
	print "OK.\n"
	puts "Total de edições encontradas: " + links.length.to_s

	0.upto(links.length() - 1) do |i|
		puts "Iniciando recuperação de artigos... "
		url = links[i]
		puts url
		h = get_titles_links_from_summary_url(url)
		
		if h.length < 1 then
			url = url + '/showToc'
			h = get_titles_links_from_summary_url(url)
		end
		puts "Total de Artigos: " + h.length.to_s

		counter = 1
		h.each do |k, v|
			print 'Esperando tempo limite... '
			sleep 1
			print "OK.\n"	
			print "Recuperando dados do artigo: " + counter.to_s + "... "
			counter = counter + 1
			article_data = get_data_for_article_from_url(v)	
			print "OK.\n"
			print "Criando objeto do tipo artigo... "
			article = Article.new(article_data)
			print "OK.\n"

			if !check_for_insertion(article)
				save_article_to_db(article, v)
			end
		end
	end
	
end

main()
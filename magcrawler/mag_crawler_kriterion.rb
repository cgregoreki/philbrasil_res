require 'nokogiri'
require 'open-uri'

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

def get_data_for_article_from_url(url)
	doc = Nokogiri::HTML(open(url, :allow_redirections => :safe))	
	data = Hash.new
	doc.css('meta').each do |p|
		case p.attribute('name').to_s
			when 'citation_author'
				data['author'] = p.attribute('content').to_s
			when 'DC.Description'
				#data['abstract'] = p.attribute('content').to_s
			when 'citation_fulltext_html_url'
				data['link'] = p.attribute('content').to_s
			when 'citation_journal_title'
				data['magazine'] = p.attribute('content').to_s
			when 'citation_volume'
				data['vol_number'] = p.attribute('content').to_s.to_i
			when 'citation_title'
				data['title'] = p.attribute('content').to_s
			when 'DC.Type'
				if p.attribute('content').to_s.eql? "Text.Serial.Journal" then
					data['article_type'] = 0 
				end
			when 'DC.Identifier.pageNumber'
				#data['page_number'] = p.attribute('content').to_s
			when 'citation_issue'
				data['issue'] = p.attribute('content').to_s
			when 'citation_author_institution'
				#data['institution'] = p.attribute('content').to_s
			when 'citation_firstpage'
				data['first_page'] = p.attribute('content').to_s
			when 'citation_lastpage'
				data['last_page'] = p.attribute('content').to_s
			when 'citation_date'
				date_splitted = p.attribute('content').to_s.split('/')
				year = date_splitted[1]
				data['year'] = year.to_i
			when 'keywords'
				data['keywords'] = p.attribute('content').to_s
			when 'DC.Type.articleType'
				data['article_personal_type'] = p.attribute('content').to_s
		end
	end
	data
end



def save_article_to_db(article, url)
	begin
		print_article_details(article, url)
		input = "Y"
		
		if article.title.include? "for Authors" or article.title.include? "aos autores" then
			raise 'An error has ocurred.'
		end

		if article.title == nil then
			puts "Artigo com título nulo: " + article.link
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

def main()
	print_logo
	puts "Digite a url da página das edições da revista:"
	url = ""
	# url = gets
	# url = url.chomp
	if url.eql? ""
		url = "http://www.scielo.br/scielo.php?script=sci_issues&pid=0100-512X&lng=pt&nrm=iso"
	end

	doc = Nokogiri::HTML(open(url, :allow_redirections => :safe))	
	mags = []
	doc.css("a[href]").each do |p|
		if p.attribute('href').to_s.include? "sci_issuetoc" then
			mags.push(p.attribute('href').to_s)
		end
	end
	mags = mags.uniq
	puts "Qtdade de edições: " + mags.length.to_s

	c = 1
	mags.each do |murl|
		puts "****"
		puts "Acessando revista " + c.to_s
		c = c+1
		print "Recuperando artigos... "
		doc_links = Nokogiri::HTML(open(murl, :allow_redirections => :safe))	

		links = []
		doc_links.css("a[href]").each do |p|
			if p.text.include? "texto em" then
				links.push(p.attribute('href').to_s)
			end
		end
		print "OK.\n"
		puts "Total de artigos: " + links.length.to_s

		c2 = 1
		links.each do |l|
			puts "Acessando artigo: " + c2.to_s
			c2 = c2+ 1
			print "Recuperando dados do artigo... "
			data = get_data_for_article_from_url(l)
			print "OK.\n"
			print "Criando objeto... "
			article = Article.new(data)
			print "OK.\n"
			save_article_to_db(article, l)
		end
	end
end

main()

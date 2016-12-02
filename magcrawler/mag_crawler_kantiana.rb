require 'rubygems'
require 'nokogiri'         
require 'open-uri'

def describe_all_values_and_keys_from_hash(h)
	h.each do |k, v|
		puts k + '  ' + v
	end
end

def describe_all_values_from_hash(h)
	h.each do |k, v|
		puts v
	end
end

def describe_all_keys_from_hash(h)
	h.each do |k, v|
		puts k
	end
end

def get_all_links_from_page(url, filter)
	doc = Nokogiri::HTML(open(url))	
	h_gross = Hash[doc.xpath('//a[@href]').map {|link| [link.text.strip, link["href"]]}]
	h_filtered = Hash.new

	h_gross.each do |k, v|
		if v.include? filter
			h_filtered[k] = v
		end
	end

	if filter != nil then
		h_filtered
	else 
		h_gross
	end

end

def get_data_for_article_from_url(url)
	doc = Nokogiri::HTML(open(url))	
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
		end
	end
	data
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

def get_data_from_all_kantia_articles_and_save()
	initial = 1
	limit = 259
	url_rad = "http://www.sociedadekant.org/studiakantiana/index.php/sk/article/view/"

	puts 'Iniciando parte de extração total de artigos - Studia Kantiana, artigos ' + initial.to_s + ' a ' + limit.to_s

	initial.upto(limit) do |i|
		url = url_rad + i.to_s
		print "Recuperando dados do artigo: " + i.to_s + "  ... "
		article_data = get_data_for_article_from_url(url)	
		print "OK.\n"
		print "Criando objeto do tipo artigo... "
		article = Article.new(article_data)
		print "OK.\n"

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
end

def test
	
	url = "http://www.sociedadekant.org/studiakantiana/index.php/sk/article/view/182"
	#url = "https://periodicos.ufsc.br/index.php/principia/article/view/1808-1711.2015v19n2p183"
	#puts "url: " + url

	article_data = get_data_for_article_from_url(url)
	article_data
end

get_data_from_all_kantia_articles_and_save()
#!/usr/bin/env ruby
# Author: Anidear
# usage: search_hackdb.rb SEARCH WORDS

require 'hpricot'
require 'open-uri'
require 'uri'

if ARGV.size < 1
	puts "Usage: search_hackdb.rb SEARCH WORDS"
	exit 1
end

# reveal concealed email in url 
def reveal_email(crypted)
	r = crypted[0..1].to_i(16)
	plain = crypted[2..-1].scan(/../).map{|i| i.to_i(16)^r}.pack('C*')
	return plain
end

# Parse page for site data
def parse_page(doc)
	results = []
	sites = doc.search('//table[@class="sTable"]/tbody/tr')
	sites.each do |site|
		#remove all scripting 
		site.search('//script').remove

		#parse text from each table cell
		cols = site.search('//td')
		site = Hash.new
		site[:time] = cols[0].inner_text
		site[:name] = cols[1].inner_text
		site[:team] = cols[2].inner_text
		site[:country] = cols[6].attributes['title']
		site[:site] = cols[8].inner_text
		if site[:site] =~ /\[email protected\]/
			cols[8].search('//a').each do |hidden_email|
				hidden_email.inner_html = reveal_email(hidden_email.attributes['data-cfemail'])
			end
			site[:site] = cols[8].inner_text
		end
		site[:os] = cols[9].inner_text
		site[:mirror] = cols[10].search('//a').attr('href')
		results << site
	end
	return results
end

word = ARGV.join('+')
cookie = ''
results = []
total_deface = 0

begin
	# Get the first page
	warn "Parsing page #1"
	open("http://www.hack-db.com/search.html?q=#{word}") do |page|
		cookie = page.meta['set-cookie'].scan(/PHPSESSID=[0-9a-f]+/)[0]
		doc = Hpricot(page)
		total_deface = doc.search('//div[@class="sItem ticketsStats"]/h2/a').text.gsub(/\D+/,'').to_i
		unique_deface = doc.search('//div[@class="sItem visitsStats"]/h2/a').text.gsub(/\D+/,'').to_i
		home_deface = doc.search('//div[@class="sItem usersStats"]/h2/a').text.gsub(/\D+/,'').to_i
		special_deface = doc.search('//div[@class="sItem ordersStats"]/h2/a').text.gsub(/\D+/,'').to_i
		warn "Statistics: "
		warn " - #{total_deface} Total Defaces"
		warn " - #{unique_deface} Unique Defaces"
		warn " - #{home_deface} Home Defaces"
		warn " - #{special_deface} Special Defaces"
		results += parse_page(doc)
	end

	total_pages = (total_deface / 25.0).ceil

	# Get the other pages
	prev_size = results.size
	cur_size = results.size
	(2..total_pages).each do |page_no|
		warn "Parsing page ##{page_no}"
		open("http://www.hack-db.com/search_#{page_no}.html",'Cookie' => cookie) do |page|
			doc = Hpricot(page)
			results += parse_page(doc)
		end
		
		results.uniq!
		cur_size = results.size
		warn "Results size = #{cur_size}"
		
		# check if no more new result
		if prev_size == cur_size
			break
		else
			prev_size = cur_size
		end
	end
rescue SystemExit, Interrupt
	# do the thing below (print result then exit)
rescue Exception => e
	# other exception exit immediately
	raise
end

# print results as CSV
results.each do |site|
	puts site.values.join("\t")
end

#!/usr/bin/env ruby
# encoding: UTF-8

# Reverse IP to domain names
# Author: Anidear

# command for install pre-requisite: 
# => gem install hpricot

require 'rubygems'
require 'optparse'
require 'socket'
require 'open-uri'
require 'hpricot'

# Parsing Input
options = {}
OptionParser.new do |opts|
	opts.banner = "Usage: reverse_dns.rb [options] IP"

	opts.on("-v", "--verbose", "Run verbosely") do |v|
		options[:verbose] = v
	end

	opts.on("-n", "--name", "Show name of the domain") do |n|
		options[:show_name] = n
	end

	opts.on("-h", "--help", "Display help message") do |n|
		puts opts
		exit
	end	
end.parse!

if ARGV.size >= 1
	if ARGV[0] =~ /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/
		#input as IP
		ip = ARGV[0]
		puts "Using IP address : #{ip}"
	else
		#input as hostname
		ip_list = Socket.getaddrinfo(ARGV[0],nil,:INET,:RAW).map{|result| result[3]}
		if ip_list.empty?
			puts "Invalid hostname: cannot retrieve IP address from #{ARGV[0]}"
			exit
		else
			puts "Found #{ip_list.size} IP : #{ip_list.to_s}"
			puts "Using the first IP : #{ip_list[0]}"
			ip = ip_list[0]
		end
	end
else
	ip = '210.1.61.196'	# default ip address of stephack.com
	puts "Using IP address : #{ip}"
end

# contants
BASE_DOMAIN = 'http://www.bing.com/'
QUERY_VAR = 'search?q=ip%3a'

# Query for first page
def first_page(ip)
	# query for ip list
	query_url = BASE_DOMAIN + QUERY_VAR + ip
	doc = open(query_url){|f| Hpricot(f)}
	count = doc.search('//*[@id="count"]').inner_text.gsub(' results','').to_i
	#pages = h.search('//*[@id="results_container"]/div[2]/ul/li[2]/a')
	pagination = doc.search('//*[@id="results_container"]/div[2]/ul/li/a')
	return [doc,count,pagination]
end

# Get hostname from URL
# - url : a URL
# can be substitute by URI.host, but has some problem with non-english URL
def get_host_name(url)
	match = %r|(https?://)?(?<host>[^/]+)(/.*$)?|.match(url)
	match['host']
end

# Parsing for URLs from a given Hpricot HTML page
# - doc : Hpricot HTML page
# - domains : Hash for store output parsed domains
def parse_for_urls(doc, domains)
	links = doc.search('//*[@id="wg0"]/li/div/div/div[1]/h3/a')
	links.each do |link|
		domain = get_host_name(link.attributes['href'])
		domains[domain] = link.inner_text
	end
	return domains
end

####### MAIN #######
domains = Hash.new

# getting the first query
doc, count, pagination = first_page(ip)
puts "Total %d links" % count if options[:verbose]

# parsing links from the first page
puts 'Parsing first page...' if options[:verbose]
parse_for_urls(doc, domains)
puts "Current number of domains = #{domains.size}" if options[:verbose]

# for next pages
pagination.each do |page|
	#skip if pagination = [NEXT,PREVIOUS]
	next if page.inner_text =~ /^Next/i or page.inner_text =~ /^Prev/i or page.attributes['href'].empty?

	#extract url of the next page
	next_page_url = BASE_DOMAIN + page.attributes['href']
	puts 'Page: %s : %s' % [page.inner_text,next_page_url] if options[:verbose]

	#fetch next page, and parse for domains	
	doc = open(next_page_url){|f| Hpricot(f)}
	parse_for_urls(doc, domains)
	puts "Current number of domains = #{domains.size}" if options[:verbose]
end

# display
domains.each do |domain,name|
	if options[:show_name]	
		# display with name of the domain
		puts "%s\t%s" % [domain,name]
	else	
		#display just the domain
		puts domain
	end
end

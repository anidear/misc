#!/usr/bin/env ruby

# Scan range of IP from an incoming IP
# ex. input=8.8.8.8 , output => 8.0.0.0 - 8.255.255.255

# Require 'whois' gem, which can be install by
# => gem install whois

require 'rubygems'
require 'whois'
require 'optparse'

# Parsing Input
options = {}
OptionParser.new do |opts|
	opts.banner = "Usage: ip2range.rb [options] IP"

	opts.on("-v", "--verbose", "Run verbosely") do |v|
		options[:verbose] = v
	end

	opts.on("-h", "--help", "Display help message") do |n|
		puts opts
		exit
	end	
end.parse!

if ARGV.size >= 1
	ip = ARGV[0]
else
	ip = '210.1.61.196'	# default ip address of stephack.com
end

##### MAIN #####
record = Whois.whois(ip)
puts record
puts '-'*80
# Inetname (Range)
puts record.to_s.scan(/^inetnum:\s+(\d+\.\d+\.\d+\.\d+)\D+(\d+\.\d+\.\d+\.\d+)/i)
puts record.to_s.scan(/^NetRange:\s+(\d+\.\d+\.\d+\.\d+)\D+(\d+\.\d+\.\d+\.\d+)/i)
puts record.to_s.scan(/^CIDR:\s+(\d+\.\d+\.\d+\.\d+\/\d+)/i)

# Netname
puts record.to_s.scan(/^netname:\s+([^\n]+)/)
puts record.properties

puts record.properties[:created_on]
puts record.properties[:updated_on]
puts record.properties[:expired_on]

puts record.properties[:registrar]

puts record.properties[:registrant_contacts]

puts record.properties[:admin_contacts]

puts record.properties[:technical_contacts]

puts record.properties[:nameservers]
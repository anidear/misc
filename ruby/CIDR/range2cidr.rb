#!/usr/bin/env ruby

def range2cidr(ip1,ip2)
	if ip1 !~ /\d{1,3}.\d{1,3}.\d{1,3}.\d{1,3}/
		STDERR.puts "Error malform IP #{ip1}"
		return ''
	end
	if ip2 !~ /\d{1,3}.\d{1,3}.\d{1,3}.\d{1,3}/
		STDERR.puts "Error malform IP #{ip2}"
		return ''
	end

	ip1 = ip1.split('.').map{|i| i.to_i}
	ip2 = ip2.split('.').map{|i| i.to_i}
	bits = ip1.zip(ip2).map { |data| 
		data = data[0]^data[1]
		count=0
		while data>0
			count+=1 if data%2==1
			data /= 2
		end
		count
	}
	bits = 32-bits.inject(&:+)
	return "#{ip1.join('.')}/#{bits}"
end

if ARGV.size>0
	# argument mode
	if ARGV.size<2
		puts "Usage: range2cidr.rb IP_start IP_end"
		puts "Ex: range2cidr.rb 192.168.1.0 192.168.1.255"
		puts "Ex: cat iplist.txt | range2cidr.rb"
		exit 1
	end
	puts range2cidr(ARGV[0], ARGV[1])
else
	# stdin mode
	while input = STDIN.gets
		ip_array = input.chomp.split(/[ \t,:+]/)
		if ip_array.size < 2
			STDERR.puts "Error an IP address missing."
		else
			puts range2cidr(ip_array[0],ip_array[1])
		end
	end

end

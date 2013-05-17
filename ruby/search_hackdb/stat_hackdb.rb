#!/usr/bin/env ruby

if ARGV.size < 1 
	puts "Usage: stat_hackdb.rb FILE"
	exit!
end

player_stat = Hash.new(0)
team_stat = Hash.new(0)
year_stat = Hash.new(0)
month_stat = Hash.new(0)

open(ARGV[0],'r') do |f|
	f.each_line do |line|
		player, team = line.split("\t")[1..2]
		year, month = line.scan(/^(\d{4})-(\d{2})/)[0]
		player_stat[player] += 1
		team_stat[team] += 1
		year_stat[year] += 1
		month_stat["#{year}-#{month}"] += 1
	end
end


def print_result(title,data)
	puts title
	puts '-' * 20
	data.keys.sort.each do |key|
		puts "#{key}\t=>\t#{data[key]}"
	end
end

# print players result
print_result("Player Statistic", player_stat)
puts '*' * 80

# print team result
print_result("Team Statistic", team_stat)
puts '*' * 80

# print annually result
print_result("Annually Statistic", year_stat)
puts '*' * 80

# print monthly result
print_result("Monthly Statistic", month_stat)

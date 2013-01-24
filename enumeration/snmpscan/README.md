This script scans all addresses in the input network,then grep for username and password. 

This script relies on 'nmap' and 'snmpwalk' program, and super-user priviledge for nmap.

author: Anidear

Usage: 
	
	snmpscan ipaddress/netmask [community_string] [grep_string]
	
Example: 

	- snmpscan 192.168.1.0/24
	- snmpscan 192.168.1.0/24 ADSL
	- snmpscan 192.168.1.0/24 ADSL truehisp
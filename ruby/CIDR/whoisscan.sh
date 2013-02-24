#!/bin/bash

for ip in $(cat ips.txt)
do
	info=$(whois -H $ip | grep -A1 "netname"|sed 's/^.*: */\|/g')
	netname=$(echo -n $info|cut -d'|' -f2)
	descr=$(echo -n $info|cut -d'|' -f3)
	echo -e "$ip\t$netname\t$descr"
done
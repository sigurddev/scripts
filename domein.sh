#!/bin/bash
# root@cadra.nl
clear
versie=$(echo vA01)
datumtijd=$(date "+%Y%m%d - %T")
echo :: Examples of healthy DMARC policies ::>domein.txt
echo [ DNS: _dmarc  TXT  "v=DMARC1; p=quarantine; sp=reject; fo=0; pct=100" ] >>domein.txt
echo [ DNS: _dmarc  TXT  "v=DMARC1; p=reject; sp=reject; fo=1; pct=100" ] >>domein.txt
echo [ TXT: query met nslookup -query=txt $1 ] >>domein.txt
echo [ GO2: https://dmarc.org/overview ] >>domein.txt

test -z $1

if [ $? = 0 ]

then
	echo Use domainname as a parameter
	exit
else
	echo 
	echo ==$versie======[ $1 ]======
	echo Start: $datumtijd
	echo
	curl -I -s https://www.$1 >domcurl1.tmp
	wwwipv4=$(host $1 | grep "has address" | awk '{print $4}')
	wwwipv6=$(host $1 | grep "has IPv6 address" | awk '{print $5}')

	#if $wwwipv6 = "" wwwipv6=$(echo No IPv6) fi

	redirornot=$(curl -I -s http://www.$1 | grep "HTTP/1.1 3" | sed -r 's/.{9}//')
	rediraddrs=$(curl -I -s http://www.$1 | grep "Location: " | awk '{print $2}')
	mxcount=$(	host $1 | grep "mail is handled by" | wc -l)
	
	nswww=$(nslookup $1 | grep -i address | grep -v 194.109)
	nsspf=$(dig -t TXT $1 | grep -i "v=spf1" | awk '{ print $5" "$6" "$7" "$8" "$9" "$10" "$11" "$12" "$13" "$14" "$15" "$16" "$16" "$17" "$18" "$19" "$20" "$21" "$22" "$23" "$24" "$25" "$26" "$27" "$28" "$29" "$30" "$31" "$32" "$33" "$34" "$35" "$36" "$37" "$38" "$39" "$40" "$41" "$42" "$43" "$44" "$45" "$46" "$47" "$48" "$49" "$50}')
	nsdnsnr=$(host -t ns $1 | wc -l)
	ipdnsnr=$(host -C $1 | grep -i nameserver | wc -l)
	mailsrvs=$(host $1 | grep -i "mail is handled by" | wc -l)

	dmarc=$(dig -t TXT _dmarc.$1| grep -i "v=dmarc" | awk '{ print $5" "$6" "$7" "$8" "$9" "$10" "$11" "$12" "$13" "$14" "$15" "$16" "$16" "$17" "$18" "$19" "$20" "$21" "$22" "$23" "$24" "$25" "$26" "$27" "$28" "$29" "$30" "$31" "$32" "$33" "$34" "$35" "$36" "$37" "$38" "$39" "$40" "$41" "$42" "$43" "$44" "$45" "$46" "$47" "$48" "$49" "$50}')
	dnssec=$(whois $1 | grep -i dnssec | awk '{print $2}')
	hsts=$(grep Strict-Transport-Security domcurl1.tmp | awk '{ print $2 }')
	if [ ! $hsts ] ; then
		hsts=$(echo no)
	fi
	websrvr1=$(grep Server: domcurl1.tmp | awk '{ print $2 }')
	websrvrred1=$(grep "HTTP/1.1 3" domcurl1.tmp)
	websrvrloc1=$(grep "Location:" domcurl1.tmp)

	echo  __[ DNS servers van $1 ]__
	host -t ns $1 | sort -n
	#echo 
	#host -C -4 $1 | awk '{print $2}' | grep ":" | sed 's/.$//'
	#echo
	#host -C -6 $1 | awk '{print $2}' | grep ":" | sed 's/.$//'
	echo
	echo DNSSEC .....: $dnssec
	echo HSTS .......: $hsts
	echo
	echo Webserver is: $websrvr1
	echo URL is .....: www.$1
	echo IPv4 adres .: $wwwipv4
	echo IPv6 adres .: $wwwipv6
	echo HTTP redir .: $redirornot
	echo To url .....: $rediraddrs
	echo
	echo Domein $1 heeft $mxcount MX records
	host $1 | grep "mail is handled by" | awk '{print $6"  "$7}' | sort -n
	echo ---
	echo SPF ........: $nsspf
	echo DMARC ......: $dmarc
	echo
	echo cat domein.txt voor DMARC voorbeelden
	echo
	datumtijd=$(date "+%Y%m%d - %T")
	echo Einde: $datumtijd
	echo
	rm -rf domcurl1.tmp
	#rm -rf domein.txt
fi

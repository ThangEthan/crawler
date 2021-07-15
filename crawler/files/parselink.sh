#!/bin/zsh
count=0
line=0
RED='\033[0;31m'
NC='\033[0m' # No Color
GREEN='\033[0;32m'
~/refresh_vpn.sh
source ~/.zshrc
mysql --local-infile=1 scraping_data -e "TRUNCATE TABLE link_compare; DROP TABLE IF EXISTS link_compare_sold; DROP TABLE IF EXISTS link_compare_rented;"

req() #make request and process output
{
	line=$(timeout 10 links2 -source https://www.funda.nl/$2/heel-nederland/$3/p$1 | lynx -dump -listonly -nonumbers -stdin | sed 's/file\:\/\/localhost/https\:\/\/www.funda.nl/g' | awk '/Hidden links:/,0' | grep -e "https\:\/\/www.funda.nl\/\(koop\|huur\)\/.*" | grep -P '^(?!.*\/p[0-9].*).*$' > ~/house/link.txt | wc -l)
	echo "$line results"
}

for i in {$1..$2}
do
	echo "Parsing page $i"
	req $i $3 $4
	while [[ $line -eq 0 ]] ; do
		echo "Retrying"
		~/refresh_vpn.sh
		echo "Parsing page $i"
		req $i $3 $4
		count=$((count+1))
		if [[ $count -ge 10 ]]
		then 
			echo "${RED}$(date '+[%d:%m:%Y] %H:%M'): Error, got more than 10 consecutive bad parse links request. Proceed to reboot.${NC}" >> ~/cron.log
			echo UHC1!!! | sudo -S reboot
		fi	
	done
	mysql --local-infile=1 scraping_data -e "LOAD DATA LOCAL INFILE '/root/house/link.txt' IGNORE INTO TABLE link_compare (url);"
	count=0
	nordvpn_refresh=$i%20
	if [[ $nordvpn_refresh -eq 0 ]]
	then
		echo "Refreshing vpn connection"
		~/refresh_vpn.sh
		sleep 0.5
	else
		sleep 0.5
	fi
done


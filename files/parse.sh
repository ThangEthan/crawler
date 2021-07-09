#!/bin/zsh
#$1: link Id, $2: scraper to run, $3: list of link to go through
count=0
line=0
RED='\033[0;31m'
NC='\033[0m' # No Color
GREEN='\033[0;32m'
source ~/.zshrc
req()
{
	line=$(timeout 10 links2 -source $link > ~/house/some_random_house.html | wc -l)
}

echo "Parsing link no.$1"
link=$(mysql -s -N scraping_data -e "SELECT URL FROM $3 WHERE ID = $1;")
req
while [[ $line -lt 300 ]]; # bad response goes here
do
	echo "Retrying. Refreshing vpn connection"
	~/refresh_vpn.sh
	req
	count=$((count+1))
	if [[ $count -ge 10 ]]
	then
		echo "${RED}$(date '+[%d:%m:%Y] %H:%M'): Error, got more than 10 consecutive bad request. Proceed to reboot.${NC}" >> ~/cron.log
		echo UHC1!!! | sudo -S reboot
	fi
done

#scrapy crawl $2 > /dev/null 2>&1
scrapy crawl $2 >> ~/scrape.log 2>&1
nordvpn_refresh=$1%20
if [[ $nordvpn_refresh -eq 0 ]]
then
	echo "Refreshing vpn connection"
	~/refresh_vpn.sh
fi
mysql -s -N scraping_data -e "DELETE FROM $3 where ID = $1"


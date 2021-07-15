#!/bin/zsh

source ~/.zshrc
cd ~/reserved

~/refresh_vpn.sh

mysql -s -N scraping_data -e "TRUNCATE TABLE reserved"

for i in {$1..$2}
do
        echo "Parsing page $i"
        line=$(timeout 10 links2 -source https://www.funda.nl/koop/heel-nederland/in-onderhandeling/sorteer-datum-af/p$i > ~/house/some_random_house.html | wc -l)
        #echo "$line results"
        while [[ $line -lt 2000 ]] ; do
                echo "Retrying"
		~/refresh_vpn.sh
                sleep 0.5
                echo "Parsing page $i"
		line=$(timeout 10 links2 -source https://www.funda.nl/koop/heel-nederland/in-onderhandeling/sorteer-datum-af/p$i > ~/house/some_random_house.html | wc -l)
                #echo "$line results"
        done
	scrapy crawl reserved > /dev/null 2>&1
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
echo "Update house"
mysql -s -N scraping_data -e "UPDATE funda f INNER JOIN reserved r ON f.url = r.url SET f.status=r.status, f.VerkochtOnderVoorbehoud = IF(ISNULL(f.VerkochtOnderVoorbehoud), r.VerkochtOnderVoorbehoud, f.VerkochtOnderVoorbehoud), f.Onderbod = IF(ISNULL(f.Onderbod), r.Onderbod, f.Onderbod);"
echo "Truncate table, scraping finished"
mysql -s -N scraping_data -e "TRUNCATE TABLE reserved"

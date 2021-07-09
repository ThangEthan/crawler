#!/bin/zsh
source ~/.zshrc
cd ~/funda-master
echo "Delete duplicate" #delete link that already present in funda table or not in right format
mysql -s -N scraping_data -e "SET SQL_SAFE_UPDATES=0; DELETE link_compare FROM link_compare INNER JOIN funda on funda.url=link_compare.url; DELETE FROM link_compare where url like 'https://www.funda.nl/%huur%';"
echo "Delete and readd ID"
mysql -s -N scraping_data -e "ALTER TABLE link_compare DROP ID; ALTER TABLE link_compare ADD ID INT NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY  KEY (ID), AUTO_INCREMENT=1"

count=$(mysql -s -N scraping_data -e "SELECT min(ID) FROM link_compare")
max=$(mysql -s -N scraping_data -e "SELECT max(ID) FROM link_compare")
~/refresh_vpn.sh
while [ $count -le $max ];
do
	~/parse.sh $count funda link_compare 
	count=$((count+1))
done
echo "Truncate table, scraping finished"
mysql -s -N scraping_data -e "TRUNCATE TABLE link_compare"

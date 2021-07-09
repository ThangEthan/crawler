#!/bin/zsh
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color
GREEN='\033[0;32m'
VPN_REFRESH=20
source ~/.zshrc
echo "${YELLOW}$(date '+[%d:%m:%Y] %H:%M'): Start funda${NC}" >> ~/cron.log
curl https://nordvpn.com/api/server | jq -r '.[] | .domain' | cut -d. -f1 > server.txt
~/parselink.sh $1 $2 koop beschikbaar/sorteer-datum-af
~/parse_ad_sell.sh
~/parselink.sh $1 $2 koop verkocht/sorteer-datum-af
~/parse_ad_sold.sh
~/parse_reserved.sh $1 $2

echo "${GREEN}$(date '+[%d:%m:%Y] %H:%M'): Finished running funda${NC}" >> ~/cron.log

#!/bin/zsh
count=0
RED='\033[0;31m'
NC='\033[0m' # No Color
GREEN='\033[0;32m'
sleep 1
timeout 60 docker exec nordvpn /bin/bash -c "nordvpn c $(shuf -n 1 ~/server.txt)"
s=$?
while [[ $s -eq 1 ]];
do
#	echo UHC1!!! | sudo -S systemctl stop nordvpnd.service
#	echo UHC1!!! | sudo -S systemctl start nordvpn.service
	sleep 1
	timeout 60 docker exec nordvpn /bin/bash -c "nordvpn c $(shuf -n 1 ~/server.txt)"
	s=$?
	count=$((count+1))
	if [[ $count -ge 20 ]]
	then
		echo "${RED}$(date '+[%d:%m:%Y] %H:%M'): Error, got more than 20 consecutive VPN connection error. Proceed to reboot.${NC}" >> ~/cron.log
		echo UHC1!!! | sudo -S reboot
	fi	
done

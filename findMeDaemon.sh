#!/bin/bash
#set -x
cd /var/mobile/Library/findMe
echo "Startup @ $(date +%d-%m-%Y\ %H:%M:%S)"
SETTINGSFILE="/var/mobile/Library/Preferences/com.yourcompany.findme.plist"
interval=$(plutil -key daemon-interval $SETTINGSFILE)
echo "Interval is $interval Minutes"

timeMinutes=$(($(date +%s)/60))
tmp=$(($timeMinutes%$interval))
diff=$(($interval-$tmp))
echo "Waiting $diff Minutes till Start"
newTime=$((($timeMinutes+diff)*60))
echo "so starttime is $(date -d @$newTime)."

while true
do
  if [[ $(date +%s) -ge $newTime ]]; then
    break
  fi
  sleep 5
done
set -x
while true
do
  ./findMe.sh &
  PID=$!
  echo "$(date +%d-%m-%Y\ %H:%M:%S): Start waiting for $interval Minutes."
  echo "Next start is at $(date -d "$interval Minutes")."
  sleep ${interval}m
done


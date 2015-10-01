#!/bin/bash
set -x
cd ${0%/*}
RUNS=1
TMPLOG=Log.tmp
LOG=Log.log
SETTINGSFILE="/var/mobile/Library/Preferences/com.yourcompany.findme.plist"

if [[ -e $SETTINGSFILE ]]; then
 enabled=$(plutil -key enabled $SETTINGSFILE)
else
  echo "Settings file missing. Exiting..."
  exit_
fi

function exit_(){
  echo "End: $(date +%d-%m-%Y\ %H:%M:%S)"
  exit 0
}

function log(){
  echo "$1" >> $TMPLOG	
}

function daemonSettings(){
  DAEMONFILE="/System/Library/LaunchDaemons/com.yourcompany.findme.plist"
  daemonInterval=$(plutil -key daemon-interval $SETTINGSFILE)
  echo "Changing Daemon Interval to run every $daemonInterval minutes." >> $TMPLOG
  plutil -key StartCalendarInterval -remove $DAEMONFILE
  plutil -key StartCalendarInterval -array $DAEMONFILE
  dictCounter=0
  for (( i=0; i<60; i=$i+$daemonInterval )){
    plutil -key StartCalendarInterval -arrayadd -dict $DAEMONFILE
    plutil -key StartCalendarInterval -key $dictCounter -key Minute -value $i -type integer $DAEMONFILE
    dictCounter=$(($dictCounter+1))
  }
  
  plutil -key RunAtLoad -false $DAEMONFILE
  launchctl unload $DAEMONFILE
  launchctl load $DAEMONFILE
  plutil -key RunAtLoad -true $DAEMONFILE
  
}

function mvLog(){
  PREFERENCEPLIST="/Library/PreferenceLoader/Preferences/findMe/com.yourcompany.findme.plist"
  
  if [[ $(whoami) == "root" ]]; then
    plutil -value "$(cat $TMPLOG)" -key items -key 2 -key footerText $PREFERENCEPLIST
    if [[ $1 != "no" ]]; then
      killall -9 Preferences
    fi
  fi
  
  cat $TMPLOG >> $LOG
  rm $TMPLOG
}

function cleanUp() {
  
  if [[ "$locationStatus" -eq 0 ]]; then
    activator send switch-off.com.a3tweaks.switch.location
  fi
  
  if [[ "$airplaneStatus" -eq 1 ]]; then
    activator send switch-on.com.a3tweaks.switch.airplane-mode
  fi
  
  if [[ "$dataStatus" -eq 0 ]]; then
    switch-off.com.a3tweaks.switch.cellular-data
  fi
  
  rm loc.tmp
  rm inet.tmp
  
  mvLog
  
  exit_
}

trap cleanUp SIGTERM SIGINT

echo "Start: $(date +%d-%m-%Y\ %H:%M:%S)" >> $TMPLOG

while [[ $# -gt 0 ]] && [[ ."$1" = .-* ]] ;
do
  opt="$1";
  shift;           #expose next argument
  case "$opt" in
    "-c" )
      daemonSettings;
      mvLog no;
    exit_;;
    "-r" )
      
      RUNS="$1";
      if [[ $RUNS -lt 1 ]]; then
        log "Less than one run? Okay... Extiting...";
        cleanUp;
      fi
    shift;;
    "-o" )
    OVERRIDE=1;;
    "-n" )
    NOTIFY=1;;
    *) echo >&2 "Invalid option: $opt"; exit_;;
  esac
done

if [[ "$enabled" != 1 ]] && [[ -z "$OVERRIDE" ]]; then
  log "Disabled... exiting"
  sleep 10
  mvLog
  exit_
fi


# Get all Settings
dataStatus=0
grep fCellularDataIsEnabled=0x0 /var/wireless/Library/Preferences/csidata || dataStatus=1
locationStatus=$(plutil -key LocationServicesEnabled /var/mobile/Library/Preferences/com.apple.locationd.plist)
airplaneStatus=$(plutil -key AirplaneMode /var/preferences/SystemConfiguration/com.apple.radios.plist)
ringerStatus=$(plutil -key SBRingerMuted /var/mobile/Library/Preferences/com.apple.springboard.plist)
url=$(plutil -key url $SETTINGSFILE)
pingHost=$(plutil -key pingHost $SETTINGSFILE)
timeout=$(plutil -key timeout $SETTINGSFILE)
password=$(plutil -key password $SETTINGSFILE)
activator send switch-on.com.a3tweaks.switch.cellular-data
activator send switch-on.com.a3tweaks.switch.location
activator send switch-off.com.a3tweaks.switch.airplane-mode
OUTPUT=loc.tmp
PROGRAM=./LcMe
echo "$(date +%d-%m-%Y\ %R): Will do $RUNS run/s" >> $TMPLOG
until [[ $RUNS -lt 1 ]];
do
  $PROGRAM > $OUTPUT  &
  PID=$!
  #echo Program is running under pid: $PID >> $TMPLOG
  
  SEARCH_STRING=5.00m
  START_TIME=$(date +%s)
  while true; do
    ! grep $SEARCH_STRING $OUTPUT || break
    curr=$(date +%s)
    diff=$(expr $curr - $START_TIME)
    
    if [[ $diff -gt $timeout ]]; then
      break
    fi
    
    sleep 4
  done
  
  kill $PID || echo "Killing process with pid $PID failed, try manual kill with -9 argument" >> $TMPLOG
  
  if ! [[ -s loc.tmp ]]; then
    echo "Sorry, error while getting location... :(" >> $TMPLOG
    cleanUp
  fi
  
  
  ping $pingHost &> inet.tmp
  
  conn=0
  grep "unknown host" inet.tmp || conn=1
  
  if [[ "$conn" -lt 1 ]]; then
    
    cat loc.tmp | tail -n 5 >> noconn.cache
    echo 'No Inet... caching...' >> $TMPLOG
    
  else
    
    if [[ -s noconn.cache ]]; then
      
      echo "Cache file present. Merging..." >> $TMPLOG
      cat noconn.cache > tmp.tmp
      cat loc.tmp | tail -n 5 >> tmp.tmp
      info=$(cat tmp.tmp | base64 -w 0)
      rm tmp.tmp
      echo "Removing Cache file" >> $TMPLOG
      rm noconn.cache
      
    else
      
      info=$(cat loc.tmp | tail -n 5 | base64 -w 0)
      
    fi
    
    postData="info=$info"
    
    if [[ $NOTIFY -eq 1 ]]; then
      postData=$postData&notify=1
      echo $postData
    fi
    
    curl -v --retry 10 --retry-delay 1 --data $postData $url >> $TMPLOG
    echo $info | base64 -d >> $TMPLOG
    echo >> $TMPLOG
  fi
  echo '###########' >> $TMPLOG
  
  RUNS=$(($RUNS-1))
done

cleanUp




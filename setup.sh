#!/bin/bash
if [[ $(whoami) != "root" ]]; then
  echo "Must be root!"
  exit 1
fi

if [[ "$1" -eq "remove" ]]; then
   launchctl stop com.yourcompany.findme
   launchctl unload /Library/LaunchDaemons/com.yourcompany.findme.plist
   killall -15 Preferences
   rm -r /Library/PreferenceLoader/Preferences/findMe
   rm /Library/LaunchDaemons/com.yourcompany.findme.plist
   killall -15 findMe.sh
   killall -15 findMeDaemon.sh
   rm /usr/bin/findMe.sh
   rm /usr/bin/findMeDaemon.sh
   echo "Daemon removed"
   exit
fi

#Preference Loader
cp -r Library/PreferenceLoader/Preferences/findMe /Library/PreferenceLoader/Preferences/findMe
chown -R root:wheel /Library/PreferenceLoader/Preferences/findMe
chmod -R 755 /Library/PreferenceLoader/Preferences/findMe

#LaunchDaemon
cp Library/LaunchDaemons/com.yourcompany.findme.plist /Library/LaunchDaemons/com.yourcompany.findme.plist
chown -R root:wheel /Library/LaunchDaemons/com.yourcompany.findme.plist
chmod 644 /Library/LaunchDaemons/com.yourcompany.findme.plist

#Preference File
if [[ ! -e /var/mobile/Library/Preferences/com.yourcompany.findme.plist ]]; then
 cp var/mobile/Library/Preferences/com.yourcompany.findme.plist /var/mobile/Library/Preferences/com.yourcompany.findme.plist
 chown mobile:mobile /var/mobile/Library/Preferences/com.yourcompany.findme.plist
 chmod 600 /var/mobile/Library/Preferences/com.yourcompany.findme.plist
fi 

cp findMe.sh /usr/bin/findMe.sh
chown root:wheel /usr/bin/findMe.sh
chmod 755 /usr/bin/findMe.sh

cp findMeDaemon.sh /usr/bin
chown root:wheel /usr/bin/findMeDaemon.sh
chmod 755 /usr/bin/findMeDaemon.sh

mkdir /var/log/findMe/

launchctl load /Library/LaunchDaemons/com.yourcompany.findme.plist
launchctl start com.yourcompany.findme
killall -15 Preferences

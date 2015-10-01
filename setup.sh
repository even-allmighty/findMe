#!/bin/bash
if [[ $(whoami) != "root" ]]; then
  echo "Must be root!"
  exit 1
fi

cp -r Library/PreferenceLoader/Preferences/findMe/Library/PreferenceLoader/Preferences/findMe
chown -R root:wheel /Library/PreferenceLoader/Preferences/findMe
chmod -R 755 /Library/PreferenceLoader/Preferences/findMe

cp Library/LaunchDaemons/com.yourcompany.findme.plist /Library/LaunchDaemons/com.yourcompany.findme.plist
chown -R root:wheel /Library/LaunchDaemons/com.yourcompany.findme.plist
chmod 644 /Library/LaunchDaemons/com.yourcompany.findme.plist

cp var/mobile/Library/Preferences/com.yourcompany.findme.plist /var/mobile/Library/Preferences/com.yourcompany.findme.plist
chown mobile:mobile /System/Library/LaunchDaemons/com.yourcompany.findme.plist
chmod 600 /System/Library/LaunchDaemons/com.yourcompany.findme.plist

cp findMe.sh /usr/bin
chown root:wheel /usr/bin/findMen.sh
chmod 755 /usr/bin/findMe.sh

cp findMeDaemon.sh /usr/bin
chown root:wheel /usr/bin/findMeDaemon.sh
chmod 755 /usr/bin/findMeDaemon.sh

mkdir /var/log/findMe/

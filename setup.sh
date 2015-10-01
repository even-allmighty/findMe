#!/bin/bash
if [[ $(whoami) != "root" ]]; then
  echo "Must be root!"
  exit 1
fi
cp -r Library/PreferenceLoader/Preferences/findMe /var/mobile/Library/PreferenceLoader/Preferences/findMe
cp System/Library/LaunchDaemons/com.yourcompany.findme.plist /System/Library/LaunchDaemons/com.yourcompany.findme.plist
cp var/mobile/Library/Preferences/com.yourcompany.findme.plist /var/mobile/Library/Preferences/com.yourcompany.findme.plist

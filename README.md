findMe
======

iPhone Background Deamon that sends the current location to a webserver of you choice :) - written (mostly in bash)

Info
======

I started writing this because I couldn't find something similar where I could be sure that my location gets only shared with my server. If you know of something please tell me :D.
Because I didn't know (and till now have been to lazy to learn) all that programming, makefile and toolchain stuff, its written in bash. This doesn't mean I'm a bash-pro but it was easier to learn (and I'm still learning. So if you find something that could/should be done in a better way I am happy to hear about that :)

Also all this was setup, tested and written on an iPhone 5 so please excuse writing mistakes and bad formatting of the code (Pull Requests welcome ;).


WARNING: THE WHOLE THING IS WORK IN PROGRESS AND TILL NOW I DIDN'T GET IT TO RUN RELIABLY (see Problems section).



How it works..
=======

Because you will understand the Setup better, read this first :)


The whole script works by using Activator by Ryan Petrich to activate all neccessary services to obtain the current location with a commandline utility called LcMe by UNKNOWN (if you know who wrote it or know an open source alternative, please tell me :)) which can be downloaded here : http://iphone.2tuto.com/index.php?2012/05/09/12/58/59-lcme-a-command-line-tool-that-displays-gps-last-locations-for-iphone (I dont know if I am allowed to publish it here).
To use Activator from the commandline it uses TerminalActivator by iolate which creates events that you can call with the included "notify_post" utility.
The Script is run by launchd either directly (see Problems section) or by the wrapper script that acts as deamon (the current state).
To provide a status it writes a Logfile and presents the output in the settingspane. You can also change different settings there.


Setup
=======

Because I use a lot of tools the setup needs some work :)

1. Things you need from cydia:  PreferenceLoader, Activator, TerminalActivator, plutil, curl, "Find Utilities" and inetutils

2. Setup the TerminalActivator Events in the Settings. Currently following events are needed:
enableGPS, disableGPS, enableData, disableData, enableAirplane, disableAirplane each of one with the corresponding activator toggle ;)

3. Copy all the Stuff of the directories to the right dirs from /.
 And the LcMe files (http://iphone.2tuto.com/index.php?2012/05/09/12/58/59-lcme-a-command-line-tool-that-displays-gps-last-locations-for-iphone) and findMe.sh and findMeDaemon.sh to /var/mobile/Library/findMe  


4. (optional) This part is incomplete and will be written as soon someone starts asking questions :P


Problems
=========

All the problems that made me change something are listed here. If I find or get the solution I may write it down here.

1. When I wanted to setup the daemon to run every 30 Minutes or so and changed the StartCalendarInterval in to an array of times (see launchd developer page from apple) the daemon didn't get started at the given times. I guess this is some kind of energysaving problem. 

2. Even with my wrapper script as daemon it doesn't work properly <-- My Current Research is on this :)

Todo
=======

Things I want to put in the script:

1. An automatic setup :P
2. Execusion of downloaded scripts, which should be encrypted to prevent misuse.
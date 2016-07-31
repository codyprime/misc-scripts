#!/bin/bash
#
# Very simple, and somewhat brain-dead, script to notify when new mail
# has arrived, via the default notification system of your desktop.
# 
# This makes use of inotify-tools.  On a Fedora-based system, install
# via 'yum install inotify-tools'
#
# Copyright 2013-2016 Jeff Cody, jeff@codyprime.org
# This is distributed as GPLv2; See LICENSE file for details.


# Use full paths, and include the "new/" diretory
# Entries should look this this, with each mailbox directory on
# its own line (sample watch file content):
# /home/Jeff.Cody/maildata/mail/redhat/INBOX/new
# /home/Jeff.Cody/maildata/mail/redhat/qemu-devel/new
# /home/Jeff.Cody/maildata/mail/redhat/important/new
MAIL_WATCH_FILE="/home/jcody/mailconfig/watched-dirs.txt"
# The icon you would like displayed.  You Gnomes might want to look
# in /usr/share/icons/gnome
ICON="/usr/share/icons/oxygen/64x64/status/mail-unread-new.png"

# milliseconds to display notification
DISPLAY_MS=5000

#SOUNDFILE="/usr/share/sounds/gnome/default/alerts/glass.ogg"
SOUNDFILE="/usr/share/sounds/KDE-Im-New-Mail.ogg"
SOUNDOPTS_END="phaser 0.6 0.66 3 0.6 2 -t"
last_msg_time=0
msg_time=0
time_diff=0

# This will loop until killed
(
while read ievent
do
    path=`echo -n $ievent|sed -e "s/[^/]*$//"`
    # this regex is a bit broken in that assumes the filename itself
    # won't have MOVED_TO or CREATE in it - which for an offline mailbox
    # file, it won't
    filename=`echo -n $ievent|sed -e "s/.*\b\(MOVED_TO\|CREATE\)\b //"`
    mailbox=${path:0:-5}  # get rid of "new/"
    mailbox=${mailbox##/*/} # get rid of /*/
    from=`grep -m 1 ^From: "${path}${filename}"`
    subject=`grep -m 1 ^Subject: "${path}${filename}"`
    notify-send -t $DISPLAY_MS -i $ICON "New mail in $mailbox" "$from\n$subject"

    # If enough time has elapsed, play a sound.  Don't always play it, so we
    # don't spam the sound
    msg_time=`date +%s`
    let time_diff=${msg_time}-${last_msg_time}
    if [ ${time_diff} -gt 5 ]
    then
        play "${SOUNDFILE}" ${SOUNDOPTS_END}
        let last_msg_time=${msg_time}
    fi
done < <(inotifywait -m -e create -e moved_to --fromfile ${MAIL_WATCH_FILE})
)2>/dev/null

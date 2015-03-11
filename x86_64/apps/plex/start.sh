#! /bin/sh

PLEX_HOME="/var/lib/plexmediaserver"
MEDIA_SERVER_HOME="${PLEX_HOME}/Library/Application Support/Plex Media Server"

rm -rf /var/run/*
rm -f "${MEDIA_SERVER_HOME}/plexmediaserver.pid"

/etc/init.d/dbus start
/etc/init.d/avahi-daemon start
/etc/init.d/plexmediaserver start

tail -f "${MEDIA_SERVER_HOME}/Logs/"*.log

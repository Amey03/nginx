#!/bin/sh

# touch each file to fix docker overlayfs issues
find /etc/crontabs/* -exec touch {} \; >/dev/null 2>&1
find /etc/periodic/15min* -exec touch {} \; >/dev/null 2>&1
find /etc/periodic/daily/* -exec touch {} \; >/dev/null 2>&1
find /etc/periodic/hourly/* -exec touch {} \; >/dev/null 2>&1
find /etc/periodic/weekly/* -exec touch {} \; >/dev/null 2>&1
find /etc/periodic/monthly/* -exec touch {} \; >/dev/null 2>&1

exec /usr/sbin/crond -f -L /dev/stdout
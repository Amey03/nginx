#!/bin/sh
set -e

# Ensure /dev/log and related directories are correctly handled
# Remove /dev/log if it's not a socket, to prevent conflicts
if [ ! -S /dev/log ]; then rm -f /dev/log; fi

# Ensure the syslog-ng control directory exists
if [ ! -d /var/lib/syslog-ng ]; then mkdir -p /var/lib/syslog-ng; fi
if [ ! -S /var/lib/syslog-ng/syslog-ng.ctl ]; then rm -f /var/lib/syslog-ng/syslog-ng.ctl; fi

# Run syslog-ng with specified configuration
SYSLOGNG_OPTS="--no-caps"
exec syslog-ng -F --cfgfile=/etc/syslog-ng/syslog-ng.conf -p /run/syslog-ng/syslog-ng.pid $SYSLOGNG_OPTS
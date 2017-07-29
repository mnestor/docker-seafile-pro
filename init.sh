#!/bin/bash

if [ ! -f "/opt/seafile/service_seafile.sh" ]; then
    echo "copy service_seafile.sh"
    cp /opt/service_seafile.sh /opt/seafile
fi
if [ ! -f "/opt/seafile/crontab" ]; then
    echo "copy crontab"
    cp /opt/crontab /opt/seafile
fi

/bin/bash /opt/seafile/service_seafile.sh $1

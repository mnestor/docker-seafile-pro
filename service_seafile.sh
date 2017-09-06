#/bin/bash

cd `dirname $0`

SEAFILE_VERSION=6.1.4

log_file=/opt/seafile/log

ulimit -n 30000

if [ "$1" == "service" ]; then
    typeset -i retry_count=0
    while true
    do
        echo "" > $log_file
        echo "start seafile retry time: " $retry_count >> $log_file
        /bin/bash /opt/seafile/service_seafile.sh restart >> $log_file 2>&1
        if [ $(cat $log_file | grep -c failed) -eq 0 ]; then
            echo "start success... retry time: " $retry_count >> $log_file
            break
        fi
        retry_count=$retry_count+1
        sleep 5
    done
    service cron start
    crontab /opt/seafile/crontab
    tail -F $log_file
elif [ "$1" == "start" ]; then
    cd ./seafile-server-latest
    ./seafile.sh start
    ./seahub.sh start
elif [ "$1" == "restart" ]; then
    cd ./seafile-server-latest
    ./seafile.sh restart
    ./seahub.sh restart
elif [ "$1" == "stop" ]; then
    cd ./seafile-server-latest
    ./seahub.sh stop
    ./seafile.sh stop
elif [ "$1" == "setup" ]; then
    wget "https://download.seafile.com/d/6e5297246c/files/?p=/pro/seafile-pro-server_${SEAFILE_VERSION}_x86-64.tar.gz&dl=1" -O seafile-pro-server_${SEAFILE_VERSION}_x86-64.tar.gz
    tar xzvf seafile-pro-server_${SEAFILE_VERSION}_x86-64.tar.gz
    cd seafile-pro-server-${SEAFILE_VERSION}
    ./setup-seafile-mysql.sh
    /bin/bash /opt/seafile/service_seafile.sh start
elif [ "$1" == "bash" ]; then
    /bin/bash
else
    echo "invalid parameter"
fi

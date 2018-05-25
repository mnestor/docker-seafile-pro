#/bin/bash

cd /opt/seafile

log_file=/opt/seafile/log

ulimit -n 30000

if [ "$1" == "service" ]; then
    typeset -i retry_count=0
    while true
    do
        su user -c "echo "" > $log_file"
        echo "start seafile retry time: " $retry_count >> $log_file
        /opt/seafile/service_seafile.sh restart >> $log_file 2>&1
        if [ $(cat $log_file | grep -c failed) -eq 0 ]; then
            echo "start success... retry time: " $retry_count >> $log_file
            break
        fi
        retry_count=$retry_count+1
        sleep 5
    done
    su user -c "crontab /opt/seafile/crontab"
    tail -F $log_file
elif [ "$1" == "start" ]; then
    cd ./seafile-server-latest
    su user -c "./seafile.sh start"
    if [ "$FASTCGI" == "1" ]; then
      su user -c "SEAFILE_FASTCGI_HOST=0.0.0.0 ./seahub.sh start-fastcgi 8000"
    else
      su user -c "./seahub.sh start"
    fi
elif [ "$1" == "restart" ]; then
    cd ./seafile-server-latest
    su user -c "./seafile.sh restart"
    if [ "$FASTCGI" == "1" ]; then
      su user -c "SEAFILE_FASTCGI_HOST=0.0.0.0 ./seahub.sh restart-fastcgi 8000"
    else
      su user -c "./seahub.sh restart"
    fi
elif [ "$1" == "stop" ]; then
    cd ./seafile-server-latest
    su user -c "./seahub.sh stop"
    su user -c "./seafile.sh stop"
elif [ "$1" == "setup" ]; then
    tar xzvf /opt/seafile-pro-server_${SEAFILE_VER}_x86-64.tar.gz -C /opt/seafile
    chown -R user:user seafile-pro-server-${SEAFILE_VER}
    rm /opt/seafile/seafile-server-latest
    ln -s /opt/seafile/seafile-pro-server-${SEAFILE_VER} /opt/seafile/seafile-server-latest
    cd seafile-pro-server-${SEAFILE_VER}
    su user -c "./setup-seafile-mysql.sh"
    /opt/seafile/service_seafile.sh start
elif [ "$1" == "setup_sqlite" ]; then
    tar xzvf /opt/seafile-pro-server_${SEAFILE_VER}_x86-64.tar.gz -C /opt/seafile
    chown -R user:user seafile-pro-server-${SEAFILE_VER}
    rm /opt/seafile/seafile-server-latest && ln -s /opt/seafile/seafile-pro-server-${SEAFILE_VER} /opt/seafile/seafile-server-latest
    cd seafile-pro-server-${SEAFILE_VER}
    su user -c "./setup-seafile.sh"
    /opt/seafile/service_seafile.sh start
elif [ "$1" == "upgrade" ]; then
    CURRENT_VER=$(ls -lah | grep 'seafile-server-latest' | awk -F"seafile-pro-server-" '{print $2}')
    CURRENT_MAJOR_VER=$(echo $CURRENT_VER | awk -F"." '{print $1"."$2}')
    NEW_MAJOR_VER=$(echo $SEAFILE_VER | awk -F"." '{print $1"."$2}')
    if [ $CURRENT_VER == $SEAFILE_VER ]; then
        echo "You already have the same version installed, exit"
    else
        tar xzvf /opt/seafile-pro-server_${SEAFILE_VER}_x86-64.tar.gz -C /opt/seafile
        rm /opt/seafile/seafile-server-latest && ln -s /opt/seafile/seafile-pro-server-${SEAFILE_VER} /opt/seafile/seafile-server-latest
        cd ./seafile-pro-server-${SEAFILE_VER}/upgrade
        echo current_version: $CURRENT_VER
        echo new_version: ${SEAFILE_VER}
        if [ $CURRENT_MAJOR_VER == $NEW_MAJOR_VER ]; then
            echo "maintenance update"
            ./minor-upgrade.sh
            rm -rf /opt/seafile/seafile-pro-server-${CURRENT_VER}
        else
            echo "Big version update, Please run the matching upgrade script, and then run exit"
            ls
            su user
        fi
    fi
elif [ "$1" == "search_update" ]; then
    cd ./seafile-server-latest
    /opt/seafile/service_seafile.sh restart
    su user -c "./pro/pro.py search --clear <<EOF
y
EOF"
    su user -c "./pro/pro.py search --update"
elif [ "$1" == "clear" ]; then
    cd ./seafile-server-latest
    su user -c "./seahub.sh clearsessions"
elif [ "$1" == "gc" ]; then
    cd ./seafile-server-latest
    su user -c "./seaf-gc.sh"
elif [ "$1" == "fsck" ]; then
    cd ./seafile-server-latest
    su user -c "./seaf-fsck.sh"
elif [ "$1" == "bash" ]; then
    #su user
    /bin/bash
else
    echo "invalid parameter"
fi

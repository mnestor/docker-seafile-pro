#/bin/bash

cd /opt/seafile

log_file=/opt/seafile/log

ulimit -n 30000

function download() {
  if [ ! -d /opt/seafile/seafile-pro-server-${SEAFILE_VER} ]; then
    if [ ! -f /opt/seafile-pro-server_${SEAFILE_VER}_x86-64_Ubuntu.tar.gz ]; then
      wget -q "https://download.seafile.com/d/6e5297246c/files/?p=/pro/seafile-pro-server_${SEAFILE_VER}_x86-64_Ubuntu.tar.gz&dl=1" -O /opt/seafile-pro-server_${SEAFILE_VER}_x86-64_Ubuntu.tar.gz
    fi
    rm -rf /opt/seafile/seafile-pro-server-${SEAFILE_VER} seafile-server-latest
    tar xzf /opt/seafile-pro-server_${SEAFILE_VER}_x86-64_Ubuntu.tar.gz -C /opt/seafile
  fi
  chown -R user:user /opt/seafile/seafile-pro-server-${SEAFILE_VER}
  rm -rf /opt/seafile/seafile-pro-server-${SEAFILE_VER}/seahub/thirdpart/future-0.16.0-py2.7.egg
}

function stop() {
  cd /opt/seafile/seafile-server-latest
  su user -c "./seahub.sh stop"
  su user -c "./seafile.sh stop"
}

function start() {
  if [ ! -d /opt/seafile/seafile-server-latest ]; then
    do_setup
  fi

  # see if we need to upgrade and do it
  do_upgrade

  cd /opt/seafile/seafile-server-latest
  su user -c "./seafile.sh start"
  su user -c "./seahub.sh start"
}

function do_setup() {
  echo "Validating we have the latest downloaded"
  download
  if [ -z "${MYSQL_HOST}" ]; then
    echo "MYSQL_HOST is unset, querying user"
    while true; do
      read -p "Are you using mysql or sqlite?" yn
      case $yn in
        mysql)
          su user -c "./seafile-pro-server-${SEAFILE_VER}/setup-seafile-mysql.sh"
          break
          ;;
        sqlite)
          su user -c "./seafile-pro-server-${SEAFILE_VER}/setup-seafile.sh"
          break
          ;;
        *)
          echo "Invalid answer";;
      esac
    done
  else
    echo "MYSQL_HOST is set, doing mysql install"
    ./seafile-pro-server-${SEAFILE_VER}/setup-seafile-mysql.sh auto -n seafile
  fi
  if [ ! -f /opt/seafile/conf/admin.txt ]; then
    echo '{"password": "password", "email": "admin@test.com"}' >> /opt/seafile/conf/admin.txt
  fi
}

function do_upgrade() {
  CURRENT_VER=$(ls -lah | grep 'seafile-server-latest' | awk -F"seafile-pro-server-" '{print $2}')
  CURRENT_MAJOR_VER=$(echo $CURRENT_VER | awk -F"." '{print $1"."$2}')
  NEW_MAJOR_VER=$(echo $SEAFILE_VER | awk -F"." '{print $1"."$2}')
  if [ $CURRENT_VER == $SEAFILE_VER ]; then
      echo "You already have the same version installed, exit"
  else
      download
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
}

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    stop
    start
    ;;
  search_update)
    stop_all
    start_all
    cd /opt/seafile/seafile-server-latest
    su user -c "./pro/pro.py search --clear <<EOF
  y
  EOF"
    su user -c "./pro/pro.py search --update"
    ;;
  clear)
    cd /opt/seafile/seafile-server-latest
    su user -c "./seahub.sh clearsessions"
    ;;
  gc)
    cd /opt/seafile/seafile-server-latest
    su user -c "./seaf-gc.sh"
    ;;
  fsck)
    cd /opt/seafile/seafile-server-latest
    su user -c "./seaf-fsck.sh"
    ;;
  shell)
    /bin/bash
    ;;
  *)
    echo $"Usage: $0 {start|stop|restart|search_update|clear|gc|fsck|shell}"
esac

tail -F /opt/seafile/logs/seahub.log

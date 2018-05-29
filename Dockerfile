FROM ubuntu:16.04
MAINTAINER mnestor

WORKDIR /opt/seafile

RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y \
    vim cron wget python nginx \
    python2.7 libpython2.7 python-setuptools python-imaging python-ldap \
    python-urllib3 ffmpeg python-pip python-mysqldb python-memcache \
    python-requests openjdk-8-jre poppler-utils \
    sqlite3 libreoffice libreoffice-script-provider-python \
    && pip install boto pillow moviepy \
    && ln -sf /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java /usr/bin/ \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV SEAFILE_VER=6.2.13 SEAFILE_DIR=/opt/seafile FILESERVER_PORT=8082 MYSQL_PORT=3306
RUN wget "https://download.seafile.com/d/6e5297246c/files/?p=/pro/seafile-pro-server_${SEAFILE_VER}_x86-64_Ubuntu.tar.gz&dl=1" -O /opt/seafile-pro-server_${SEAFILE_VER}_x86-64_Ubuntu.tar.gz

RUN useradd -u 999 -d /config -m -G root,sudo user
COPY service_seafile.sh /opt
COPY crontab /opt
COPY init /
RUN chmod 770 /init

CMD ["start"]
ENTRYPOINT ["/init"]

FROM ubuntu:16.04
MAINTAINER fcying

WORKDIR /opt/seafile

RUN apt-get update  \
    && apt-get install --no-install-recommends -y \
    sudo vim cron wget openjdk-8-jre poppler-utils libpython2.7 python-pip \
    python-setuptools python-imaging python-mysqldb python-memcache python-ldap \
    python-urllib3 \
    && pip install boto requests \
    && ln -sf /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java /usr/bin/ \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY service_seafile.sh /opt
COPY crontab /opt
COPY init.sh /bin
ENV SEAFILE_VER 6.1.8
RUN chmod 700 /bin/init.sh \
    && wget "https://download.seafile.com/d/6e5297246c/files/?p=/pro/seafile-pro-server_${SEAFILE_VER}_x86-64.tar.gz&dl=1" -O /opt/seafile-pro-server_${SEAFILE_VER}_x86-64.tar.gz

CMD ["service"]
ENTRYPOINT ["/bin/init.sh"]

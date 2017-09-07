FROM ubuntu:16.04
MAINTAINER fcying

WORKDIR /opt/seafile

RUN apt-get update  \
    && apt-get install --no-install-recommends -y \
    vim cron wget openjdk-8-jre poppler-utils libpython2.7 python-pip \
    python-setuptools python-imaging python-mysqldb python-memcache python-ldap \
    python-urllib3 \
    && pip install boto requests \
    && ln -sf /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java /usr/bin/ \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV SEAFILE_VER 6.1.8
RUN wget "https://download.seafile.com/d/06d4ca0272/files/?p=/seafile-pro-server_${SEAFILE_VER}_x86-64_Ubuntu.tar.gz&dl=1" -O /opt/seafile-pro-server_${SEAFILE_VER}_x86-64_Ubuntu.tar.gz

RUN useradd -u 999 -d /config -m -G root,sudo user
COPY service_seafile.sh /opt
COPY crontab /opt
COPY init /bin
RUN chmod 770 /bin/init

CMD ["service"]
ENTRYPOINT ["/bin/init"]

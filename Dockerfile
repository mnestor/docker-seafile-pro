FROM alpine:latest
MAINTAINER mnestor

WORKDIR /opt/seafile


ENV SEAFILE_VER 6.2.9
RUN wget "https://download.seafile.com/d/6e5297246c/files/?p=/pro/seafile-pro-server_${SEAFILE_VER}_x86-64.tar.gz&dl=1" -O /opt/seafile-pro-server_${SEAFILE_VER}_x86-64.tar.gz

RUN addgroup user && adduser -s /bin/sh -u 999 -h /config -D -G user user && adduser user root
COPY service_seafile.sh /opt
COPY crontab /opt
COPY init /
RUN chmod 770 /init

# Install packages
RUN apk update && \
    apk add --no-cache \
    py-pip openjdk8-jre bash py-imaging \
    py-mysqldb shadow poppler-utils \ 
    py-pyldap py-urllib3 memcached py-requests \
    && pip install boto python-memcached \
    && rm -rf /var/cache/apk/*

CMD ["service"]
ENTRYPOINT ["/init"]

# Copyright © 2021, Andreas Hackl <a@r0.at>

# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or  without fee is hereby granted,  provided that the above
# copyright notice and this permission notice appear in all copies.

FROM alpine:3.16

ARG BRANCH=master

USER root
RUN apk add git nginx php8-cli php8-fpm php8-fileinfo supervisor \
 && git clone -b $BRANCH --single-branch https://github.com/Rouji/single_php_filehost_docker.git /srv/filehost-config \
 && mv /srv/filehost-config/entry.sh /entry.sh \
 && git clone -b $BRANCH --single-branch https://github.com/Rouji/single_php_filehost.git /srv/single_php_filehost \
 && mkdir /files \
 && chown -R nginx:nobody /srv/single_php_filehost && chmod -R u=rwX,g=,o= /srv/single_php_filehost \
 && rm /etc/nginx/http.d/default.conf \
 && echo -e "#!/bin/sh\n/usr/bin/php8 /srv/single_php_filehost/index.php purge" > /etc/periodic/daily/purge && chmod u+x /etc/periodic/daily/purge\
 && chmod u+x /entry.sh \
 && apk del git && rm -rf /var/cache/apk/*

RUN mv /srv/filehost-config/vhost.conf /etc/nginx/http.d/single_php_filehost.conf \
 && mv /srv/filehost-config/supervisord.conf /etc/supervisord.conf

RUN sed -i "s/chmod -R u=rwX,g=,o= \/files/chmod -R u=rwX,g=rw,o=rw \/files/" /entry.sh

VOLUME /files
EXPOSE 80

ENTRYPOINT ["/entry.sh"]
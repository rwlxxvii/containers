FROM alpine:3

LABEL maintainer "Fluentd developers <fluentd@googlegroups.com>"
LABEL Description="Fluentd docker image" Vendor="Fluent Organization" Version="1.16.0"

RUN set -eux; \
    \
    apk update; \
    apk add --no-cache \
        ca-certificates \
        ruby ruby-irb ruby-etc ruby-webrick \
        tini; \
    apk add --no-cache --virtual .build-deps \
        build-base linux-headers \
        ruby-dev gnupg; \
    echo 'gem: --no-document' >> /etc/gemrc; \
    gem install oj -v 3.14.2; \
    gem install json -v 2.6.3; \
    gem install rexml -v 3.2.5; \
    gem install async -v 1.30.3; \
    gem install async-http -v 0.56.6; \
    gem install fluentd -v 1.16.0; \
    gem install bigdecimal -v 1.4.4; \
    gem install fluent-plugin-elasticsearch -v 5.2.5; \
    gem install fluent-plugin-cloudwatch-logs -v 0.14.3; \
    gem install fluent-plugin-grok-parser -v 2.6.2; \
    gem install fluent-plugin-s3 -v 1.7.2; \
    apk del .build-deps; \
    rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem /usr/lib/ruby/gems/3.*/gems/fluentd-*/test

RUN set -eux; \
    \
    addgroup -g 65535 fluent; \
    adduser --shell /sbin/nologin --disabled-password -h /home/fluent --uid 65535 --ingroup fluent fluent; \
    mkdir -p /fluentd/log; \
    mkdir -p /fluentd/etc /fluentd/plugins; \
    chown -R fluent /fluentd; \
    chgrp -R fluent /fluentd

COPY fluent.conf /fluentd/etc/
COPY entrypoint.sh /bin/

WORKDIR /home/fluent/

RUN set -x; \
    \
    chmod +x /bin/entrypoint.sh; \
    apk add --no-cache clamav freshclam; \
    freshclam; \
    clamscan -r -v -i -l AV_scan.log --exclude-dir="^/sys" / || :; \
    chown fluent:fluent AV_scan.log; \
    grep -Hrn FOUND AV_scan.log; \
    apk del clamav freshclam; \
    rm -rf /var/cache/apk/*; \
    truncate -s 0 /var/log/*log

ENV FLUENTD_CONF="fluent.conf"

ENV LD_PRELOAD=""
EXPOSE 24224 5140

USER fluent
ENTRYPOINT ["tini",  "--", "/bin/entrypoint.sh"]
CMD ["fluentd"]

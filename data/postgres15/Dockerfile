FROM docker.io/debian:bullseye
WORKDIR /var/lib/postgresql

ADD ./scripts /scripts
RUN find /scripts -name "*" -exec chmod +x {} \;
RUN bash -c "/scripts/postgres-install"

USER postgres

ENV PG_MAJOR=15 \
    PGUSER=postgres \
    PGHOST=/var/run/postgresql \
    PGPORT=5432 \
    PGDATA=/var/lib/postgresql/data \
    PAGER='pspg -s 0' \
    PATH="$PATH:/usr/lib/postgresql/15/bin:/scripts" \
    WALG_CONFIG_FILE=/var/lib/postgresql/.walg.json \
    LANG=en_US.utf8

ENV POSTGRES_PASSWORD=${POSTGRES_PASSWORD}

STOPSIGNAL SIGINT
ENTRYPOINT ["/scripts/entrypoint"]
CMD ["postgres"]

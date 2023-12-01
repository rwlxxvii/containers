FROM debian:bookworm-slim

ENV PG_MAJOR='15' \
    PGUSER='postgres' \
    PGHOST='/var/run/postgresql' \
    PGPORT='5432' \
    PGDATA='/var/lib/postgresql/data' \
    PAGER='pspg -s 0' \
    PATH="$PATH:/usr/lib/postgresql/15/bin:/scripts" \
    WALG_CONFIG_FILE='/var/lib/postgresql/.walg.json' \
    LANG='en_US.utf8'

WORKDIR /var/lib/postgresql

COPY --chmod=755 scripts/postgres-install /scripts
RUN bash -c "/scripts/postgres-install"

ADD ./scripts /scripts
RUN find ./scripts -name "*" -exec chmod +x {} \; 

USER postgres
STOPSIGNAL SIGINT
ENTRYPOINT ["/scripts/entrypoint"]
CMD ["postgres"]

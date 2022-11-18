FROM quay.io/minio/mc:RELEASE.2022-11-17T21-20-39Z AS mc
FROM postgres:15.1-alpine AS postgres
FROM alpine:3.16.3

COPY --from=mc /usr/bin/mc /usr/bin/mc
COPY --from=postgres /usr/local/bin/pg_dump /usr/local/bin/pg_dump
COPY --from=postgres /usr/local/lib/libpq.so.5 /usr/local/lib/libpq.so.5

RUN apk update && \
  apk add --no-cache ca-certificates \
  curl \
  bash \
  gzip \
  tzdata \
  krb5 \
  libldap

COPY run.sh env.sh /

RUN chmod +x /run.sh

ENTRYPOINT [ "/bin/sh", "-l", "-c" ]

CMD [ "/run.sh" ]

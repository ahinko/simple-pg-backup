FROM quay.io/minio/mc:RELEASE.2025-02-04T04-57-50Z AS mc
FROM postgres:17.2-alpine AS postgres
FROM public.ecr.aws/docker/library/alpine:3.21.2

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
  libldap \
  zstd-libs \
  lz4-dev

COPY run.sh env.sh /

RUN chmod +x /run.sh

ENTRYPOINT [ "/bin/sh", "-l", "-c" ]

CMD [ "/run.sh" ]

FROM quay.io/minio/mc:RELEASE.2024-07-31T15-58-33Z AS mc
FROM postgres:16.3-alpine AS postgres
FROM public.ecr.aws/docker/library/alpine:3.20.2

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

FROM quay.io/minio/mc:RELEASE.2022-08-05T08-01-28Z AS mc
FROM alpine:3.16.2

COPY --from=mc /usr/bin/mc /usr/bin/mc

RUN apk update && \
  apk add --no-cache ca-certificates bash gzip tzdata postgresql-client

COPY run.sh env.sh /

RUN chmod +x /run.sh

ENTRYPOINT [ "/bin/sh", "-l", "-c" ]

CMD [ "/run.sh" ]

#!/bin/bash

set -o nounset

source ./env.sh

HEALTHCHECK_URL=${HEALTHCHECK_URL:-""}

DELETE_OLDER_THAN=${DELETE_OLDER_THAN:-"30d"}
POSTGRES_PORT=${POSTGRES_PORT:-5432}
POSTGRES_EXTRA_OPTS=${POSTGRES_EXTRA_OPTS:-""}

########

LOCAL_PATH="./dump/"
POSTGRES_DBS=$(echo "${POSTGRES_DB}" | tr , " ")

export PGUSER="${POSTGRES_USER}"
export PGPASSWORD="${POSTGRES_PASSWORD}"
export PGHOST="${POSTGRES_HOST}"
export PGPORT="${POSTGRES_PORT}"

mkdir -p ${LOCAL_PATH}

# Configure minio cli
mc alias set minio ${MINIO_HOST} ${MINIO_ACCESS_KEY} ${MINIO_SECRET_KEY}

if [ $? != 0 ] ; then
    echo "Could not connect to minio server."
    exit 1;
fi

# Make sure bucket exists
mc mb --ignore-existing minio/${MINIO_BUCKET}
if [ $? != 0 ] ; then
    echo "Could create bucket, might be a connection problem."
    exit 1;
fi

for DB in ${POSTGRES_DBS}; do
  BACKUP_FILENAME=${DB}-$(date +%Y%m%d_%H%M%S).sql.gz
  BACKUP_PATH=${LOCAL_PATH}${BACKUP_FILENAME}

  echo "Backup $DB to $BACKUP_PATH and uploading to ${MINIO_HOST}"

  # Dump database
  pg_dump -d ${DB} ${POSTGRES_EXTRA_OPTS} | gzip -9 > ${BACKUP_PATH}

  # Upload backup
  mc cp "${BACKUP_PATH}" minio/${MINIO_BUCKET}/${BACKUP_NAME}/${BACKUP_FILENAME}
  if [ $? != 0 ] ; then
      echo "Failed to upload timestamped backup"
      exit 1;
  fi
done

# Delete old backups
mc rm -r --force --older-than ${DELETE_OLDER_THAN} minio/${MINIO_BUCKET}/${BACKUP_NAME}/
if [ $? != 0 ] ; then
    echo "Failed to delete old backups"
    exit 1;
fi

# Healtcheck
if [ "$HEALTHCHECK_URL" != "" ]; then
    echo "Curling $HEALTHCHECK_URL"
    curl -fsS -m 10 --retry 5 -o /dev/null $HEALTHCHECK_URL
fi
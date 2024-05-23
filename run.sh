#!/bin/bash

set -o nounset

source ./env.sh

HEALTHCHECK_URL=${HEALTHCHECK_URL:-""}
DELETE_OLDER_THAN=${DELETE_OLDER_THAN:-"30d"}
POSTGRES_PORT=${POSTGRES_PORT:-5432}
POSTGRES_EXTRA_OPTS=${POSTGRES_EXTRA_OPTS:-""}
COMPRESS=${COMPRESS:-false}
VERIFY_COMPRESSION=${VERIFY_COMPRESSION:-false}

########

LOCAL_PATH="./dump/"
BACKUP_FILE_EXTENSION="sql"
POSTGRES_DBS=$(echo "${POSTGRES_DB}" | tr , " ")

if [ ${COMPRESS} == true ]; then
    POSTGRES_EXTRA_OPTS="${POSTGRES_EXTRA_OPTS} -Z6"
    BACKUP_FILE_EXTENSION="sql.gz"
fi

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
  BACKUP_FILENAME=${DB}-$(date +%Y%m%d_%H%M%S)
  BACKUP_PATH=${LOCAL_PATH}${BACKUP_FILENAME}.${BACKUP_FILE_EXTENSION}

  echo "Backup $DB to $BACKUP_PATH with extra options: ${POSTGRES_EXTRA_OPTS} and uploading to ${MINIO_HOST}"

  # Dump database
  pg_dump -d ${DB} ${POSTGRES_EXTRA_OPTS} > ${BACKUP_PATH}

  # Check for errors
  if [ $? != 0 ] ; then
      echo "Failed to backup $DB"
      exit 1;
  fi

  # Verify compression
  if [[ ${COMPRESS} == true && ${VERIFY_COMPRESSION} == true ]]; then
    gunzip -c ${BACKUP_PATH} > ${BACKUP_FILENAME}.sql

    if [ $? != 0 ] ; then
      echo "Failed to decompress backup"
      exit 1;
    fi

    rm ${BACKUP_FILENAME}.sql
  fi

  # Upload backup
  mc cp "${BACKUP_PATH}" minio/${MINIO_BUCKET}/${BACKUP_NAME}/${BACKUP_FILENAME}.${BACKUP_FILE_EXTENSION}
  if [ $? != 0 ] ; then
      echo "Failed to upload timestamped backup"
      exit 1;
  fi

  rm ${BACKUP_PATH}
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
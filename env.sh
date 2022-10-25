if [ -z "$POSTGRES_DB" ]; then
  echo "You need to set the POSTGRES_DB environment variable."
  exit 1
fi

if [ -z "$POSTGRES_USER" ]; then
  echo "You need to set the POSTGRES_USER environment variable."
  exit 1
fi

if [ -z "$POSTGRES_PASSWORD" ]; then
  echo "You need to set the POSTGRES_PASSWORD environment variable."
  exit 1
fi

if [ -z "$POSTGRES_HOST" ]; then
  echo "You need to set the POSTGRES_HOST environment variable."
  exit 1
fi

if [ -z "$MINIO_BUCKET" ]; then
  echo "You need to set the MINIO_BUCKET environment variable."
  exit 1
fi

if [ -z "$MINIO_ACCESS_KEY" ]; then
  echo "You need to set the MINIO_ACCESS_KEY environment variable."
  exit 1
fi

if [ -z "$MINIO_SECRET_KEY" ]; then
  echo "You need to set the MINIO_SECRET_KEY environment variable."
  exit 1
fi

if [ -z "$BACKUP_NAME" ]; then
  echo "You need to set the BACKUP_NAME environment variable."
  exit 1
fi
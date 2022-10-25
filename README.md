# simple-pg-backup

A simple Docker container for backing up and restoring Postgres databases to a Minio server. This script is highly opinionated and tailored for my needs. **I take no responsibility so use this at your own risk.**

How the backup script in the container works: Using the `POSTGRES_DATABASE` the script will loop through the list of databases and run a `pg_dump` on the table and upload the file to a Minio server.

There is no restore option, do it manually by using `psql` or `pg_restore`.
## Enviroment variables
* `TZ` Set timezone

* `POSTGRES_DB` Databases to backup. Example: `nextcloud,postgres`

* `POSTGRES_USER` Postgres username

* `POSTGRES_PASSWORD` Postgres password for the user

* `POSTGRES_HOST` Hostname/IP to the Postgres server

* `POSTGRES_PORT` Port number to connect to

* `POSTGRES_EXTRA_OPTS` Extra arguments to pass to `pg_dump`. Example: `--encoding=utf8 --format=plain --no-owner --no-acl --no-privileges`

* `BACKUP_NAME` Filename used by the backup process to name the archived file. Example: "postgres". The script will add the current date and time to the filename.

* `MINIO_ACCESS_KEY`

* `MINIO_SECRET_KEY`

* `MINIO_HOST` Hostname and port (if needed). Example: minio.local.dev:9000

* `MINIO_BUCKET` Bucket name (must be lowercase). A subfolder based on `BACKUP_NAME` will be created. So setting `MINIO_BUCKET` to `backup` and `BACKUP_NAME` to `postgres` would upload the backup to `backup/postgres`

* `DELETE_OLDER_THAN` determines how long files should be stored. On each backup files older than this value will be deleted. Defaults to: 30d

* `HEALTHCHECK_URL` An URL that should be called after a backup has completed successfully. (Optional)


#!/bin/bash
set -euo pipefail

WEBROOT=/var/www/html
SRC=/usr/src/opencart

if [ ! -f "$WEBROOT/index.php" ]; then
    echo "==> First run: copying OpenCart into $WEBROOT"
    cp -a "$SRC/." "$WEBROOT/"
fi

cd "$WEBROOT"

echo "==> Waiting for database at ${DB_HOSTNAME}:${DB_PORT}..."
until (exec 3<>"/dev/tcp/${DB_HOSTNAME}/${DB_PORT}") 2>/dev/null; do
    sleep 2
done
exec 3<&- 3>&-
echo "==> Database is reachable"

if [ ! -f "$WEBROOT/config.php" ]; then
    echo "==> Running OpenCart CLI installer"
    cp config-dist.php config.php
    cp admin/config-dist.php admin/config.php

    php install/cli_install.php install \
        --username "$OC_ADMIN_USERNAME" \
        --password "$OC_ADMIN_PASSWORD" \
        --email "$OC_ADMIN_EMAIL" \
        --http_server "$HTTP_SERVER" \
        --db_driver mysqli \
        --db_hostname "$DB_HOSTNAME" \
        --db_username "$DB_USERNAME" \
        --db_password "$DB_PASSWORD" \
        --db_database "$DB_DATABASE" \
        --db_port "$DB_PORT" \
        --db_prefix oc_

    rm -rf install
    if [ -f .htaccess.txt ]; then
        mv .htaccess.txt .htaccess
    fi
    echo "==> Install complete"
fi

chown -R www-data:www-data "$WEBROOT"

exec "$@"

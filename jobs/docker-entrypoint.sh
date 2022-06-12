#!/usr/bin/env sh
set -eu

envsubst '${APP_HOSTNAME} ${APP_ROOT}' < /usr/local/default-site.conf.template > /etc/nginx/sites-enabled/$APP_NAME.conf

exec "$@"
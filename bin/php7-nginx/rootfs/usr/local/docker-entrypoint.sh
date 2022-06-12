#!/usr/bin/env sh
set -eu

envsubst '${APP_HOSTNAME} ${APP_ROOT}' < /usr/local/default-site.conf.template-php7 > /etc/nginx/sites-enabled/default-site.conf

exec "$@"
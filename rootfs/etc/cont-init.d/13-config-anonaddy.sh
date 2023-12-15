#!/usr/bin/with-contenv bash
# shellcheck shell=bash
set -e

. $(dirname $0)/00-env

if [ -z "$APP_KEY" ]; then
  echo >&2 "ERROR: Either APP_KEY or APP_KEY_FILE must be defined"
  exit 1
fi
if [ -z "$ANONADDY_DOMAIN" ]; then
  echo >&2 "ERROR: ANONADDY_DOMAIN must be defined"
  exit 1
fi

if [ -z "$ANONADDY_SECRET" ]; then
  echo >&2 "ERROR: Either ANONADDY_SECRET or ANONADDY_SECRET_FILE must be defined"
  exit 1
fi

echo "Creating env file"
cat >/var/www/anonaddy/.env <<EOL
APP_NAME=${APP_NAME}
APP_ENV=production
APP_KEY=${APP_KEY}
APP_DEBUG=${APP_DEBUG}
APP_URL=${APP_URL}

LOG_CHANNEL=stack

DB_CONNECTION=mysql
DB_HOST=${DB_HOST}
DB_PORT=${DB_PORT}
DB_DATABASE=${DB_DATABASE}
DB_USERNAME=${DB_USERNAME}
DB_PASSWORD=${DB_PASSWORD}

BROADCAST_DRIVER=log
CACHE_DRIVER=file
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120

REDIS_CLIENT=phpredis
REDIS_HOST=${REDIS_HOST}
REDIS_PASSWORD=${REDIS_PASSWORD}
REDIS_PORT=${REDIS_PORT}

MAIL_FROM_NAME=${MAIL_FROM_NAME}
MAIL_FROM_ADDRESS=${MAIL_FROM_ADDRESS}
MAIL_DRIVER=smtp
MAIL_HOST=127.0.0.1
MAIL_PORT=25
MAIL_ENCRYPTION=${MAIL_ENCRYPTION}

PUSHER_APP_ID=${PUSHER_APP_ID}
PUSHER_APP_KEY=${PUSHER_APP_KEY}
PUSHER_APP_SECRET=${PUSHER_APP_SECRET}
PUSHER_APP_CLUSTER=${PUSHER_APP_CLUSTER}

MIX_PUSHER_APP_KEY="${PUSHER_APP_KEY}"
MIX_PUSHER_APP_CLUSTER="${PUSHER_APP_CLUSTER}"

SANCTUM_STATEFUL_DOMAINS="$(echo "$APP_URL" | awk -F/ '{print $3}')"

ANONADDY_RETURN_PATH=${ANONADDY_RETURN_PATH}
ANONADDY_ADMIN_USERNAME=${ANONADDY_ADMIN_USERNAME}
ANONADDY_ENABLE_REGISTRATION=${ANONADDY_ENABLE_REGISTRATION}
ANONADDY_DOMAIN=${ANONADDY_DOMAIN}
ANONADDY_HOSTNAME=${ANONADDY_HOSTNAME}
ANONADDY_DNS_RESOLVER=${ANONADDY_DNS_RESOLVER}
ANONADDY_ALL_DOMAINS=${ANONADDY_ALL_DOMAINS}
ANONADDY_SECRET=${ANONADDY_SECRET}
ANONADDY_LIMIT=${ANONADDY_LIMIT}
ANONADDY_BANDWIDTH_LIMIT=${ANONADDY_BANDWIDTH_LIMIT}
ANONADDY_NEW_ALIAS_LIMIT=${ANONADDY_NEW_ALIAS_LIMIT}
ANONADDY_ADDITIONAL_USERNAME_LIMIT=${ANONADDY_ADDITIONAL_USERNAME_LIMIT}
ANONADDY_SIGNING_KEY_FINGERPRINT=${ANONADDY_SIGNING_KEY_FINGERPRINT}
ANONADDY_DKIM_SIGNING_KEY=${ANONADDY_DKIM_SIGNING_KEY}
ANONADDY_DKIM_SELECTOR=${ANONADDY_DKIM_SELECTOR}

EOL

if [ -f "/data/.env" ]; then
  cat "/data/.env" >> /var/www/anonaddy/.env
fi

chown anonaddy. /var/www/anonaddy/.env

echo "Trust all proxies"
sed -i "s|^    protected \$proxies.*|    protected \$proxies = '\*';|g" /var/www/anonaddy/app/Http/Middleware/TrustProxies.php

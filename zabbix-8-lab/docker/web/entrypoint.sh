#!/usr/bin/env bash
set -euo pipefail

: "${DB_SERVER_HOST:=postgres}"
: "${DB_SERVER_PORT:=5432}"
: "${POSTGRES_DB:=zabbix}"
: "${POSTGRES_USER:=zabbix}"
: "${POSTGRES_PASSWORD:=zabbix}"
: "${ZBX_SERVER_HOST:=zabbix-server}"
: "${ZBX_SERVER_PORT:=10051}"
: "${ZBX_SERVER_NAME:=Zabbix 8 Lab}"
: "${CLICKHOUSE_URL:=http://clickhouse:8123}"
: "${CLICKHOUSE_DB:=zabbix}"
: "${CLICKHOUSE_USER:=zabbix}"
: "${CLICKHOUSE_PASSWORD:=zabbix}"

mkdir -p /run/php /var/www/zabbix/conf

cat >/var/www/zabbix/conf/zabbix.conf.php <<PHP
<?php
\$DB['TYPE']     = 'POSTGRESQL';
\$DB['SERVER']   = '${DB_SERVER_HOST}';
\$DB['PORT']     = '${DB_SERVER_PORT}';
\$DB['DATABASE'] = '${POSTGRES_DB}';
\$DB['USER']     = '${POSTGRES_USER}';
\$DB['PASSWORD'] = '${POSTGRES_PASSWORD}';
\$DB['SCHEMA']   = '';
\$ZBX_SERVER      = '${ZBX_SERVER_HOST}';
\$ZBX_SERVER_PORT = '${ZBX_SERVER_PORT}';
\$ZBX_SERVER_NAME = '${ZBX_SERVER_NAME}';
\$HISTORY_PROVIDERS = [[
    'types' => ['uint', 'dbl', 'str', 'log', 'text', 'json'],
    'provider' => 'clickhouse',
    'url' => '${CLICKHOUSE_URL}',
    'db' => '${CLICKHOUSE_DB}',
    'username' => '${CLICKHOUSE_USER}',
    'password' => '${CLICKHOUSE_PASSWORD}'
]];
PHP

chown www-data:www-data /var/www/zabbix/conf/zabbix.conf.php
php-fpm8.3 -D
exec nginx -g 'daemon off;'

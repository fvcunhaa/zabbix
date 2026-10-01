#!/usr/bin/env bash
set -euo pipefail

: "${DB_SERVER_HOST:=postgres}"
: "${DB_SERVER_PORT:=5432}"
: "${POSTGRES_DB:=zabbix}"
: "${POSTGRES_USER:=zabbix}"
: "${POSTGRES_PASSWORD:=zabbix}"
: "${CLICKHOUSE_URL:=http://clickhouse:8123}"
: "${CLICKHOUSE_DB:=zabbix}"
: "${CLICKHOUSE_USER:=zabbix}"
: "${CLICKHOUSE_PASSWORD:=zabbix}"
: "${CLICKHOUSE_HISTORY_TTL:=2678400}"
: "${ZBX_WEBDRIVERURL:=http://selenium:4444}"
: "${ZBX_STARTBROWSERPOLLERS:=2}"
: "${ZBX_WEBSERVICEURL:=http://zabbix-web-service:10053/report}"
: "${ZBX_STARTREPORTWRITERS:=1}"
: "${ZBX_LOGLEVEL:=3}"

export PGPASSWORD="$POSTGRES_PASSWORD"

echo "[zabbix] waiting for PostgreSQL..."
until pg_isready -h "$DB_SERVER_HOST" -p "$DB_SERVER_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" >/dev/null 2>&1; do sleep 2; done

if ! psql -h "$DB_SERVER_HOST" -p "$DB_SERVER_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -Atqc \
  "SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='dbversion'" | grep -q 1; then
  echo "[zabbix] initializing PostgreSQL schema..."
  psql -v ON_ERROR_STOP=1 -h "$DB_SERVER_HOST" -p "$DB_SERVER_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /usr/share/zabbix-postgresql/schema.sql
  psql -v ON_ERROR_STOP=1 -h "$DB_SERVER_HOST" -p "$DB_SERVER_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /usr/share/zabbix-postgresql/images.sql
  psql -v ON_ERROR_STOP=1 -h "$DB_SERVER_HOST" -p "$DB_SERVER_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /usr/share/zabbix-postgresql/data.sql
fi

echo "[zabbix] waiting for ClickHouse..."
until curl -fsS -u "${CLICKHOUSE_USER}:${CLICKHOUSE_PASSWORD}" "${CLICKHOUSE_URL}/ping" >/dev/null 2>&1; do sleep 2; done

if ! curl -fsS -u "${CLICKHOUSE_USER}:${CLICKHOUSE_PASSWORD}" \
  "${CLICKHOUSE_URL}/?database=${CLICKHOUSE_DB}&query=EXISTS%20TABLE%20history_uint" | grep -q '^1'; then
  echo "[zabbix] creating ClickHouse history tables..."
  /usr/share/zabbix-clickhouse/history_all.sh \
    -s "$CLICKHOUSE_URL" \
    -d "$CLICKHOUSE_DB" \
    -u "$CLICKHOUSE_USER" \
    -p "$CLICKHOUSE_PASSWORD" \
    -t "$CLICKHOUSE_HISTORY_TTL"
fi

cat >/etc/zabbix/zabbix_server.conf <<CFG
LogType=console
LogFileSize=0
DebugLevel=${ZBX_LOGLEVEL}
PidFile=/tmp/zabbix_server.pid
SocketDir=/tmp
DBHost=${DB_SERVER_HOST}
DBPort=${DB_SERVER_PORT}
DBName=${POSTGRES_DB}
DBUser=${POSTGRES_USER}
DBPassword=${POSTGRES_PASSWORD}
HistoryProvider=clickhouse;value_types="uint,dbl,str,log,text,json",url=${CLICKHOUSE_URL},db=${CLICKHOUSE_DB},username=${CLICKHOUSE_USER},password=${CLICKHOUSE_PASSWORD}
Timeout=10
StartPollers=10
StartPollersUnreachable=2
StartPingers=2
StartHTTPPollers=3
StartDiscoverers=2
StartTrappers=5
StartLLDProcessors=2
StartDBSyncers=4
CacheSize=128M
HistoryCacheSize=64M
HistoryIndexCacheSize=32M
TrendCacheSize=32M
ValueCacheSize=64M
WebDriverURL=${ZBX_WEBDRIVERURL}
StartBrowserPollers=${ZBX_STARTBROWSERPOLLERS}
WebServiceURL=${ZBX_WEBSERVICEURL}
StartReportWriters=${ZBX_STARTREPORTWRITERS}
EnableGlobalScripts=1
FpingLocation=/usr/bin/fping
Fping6Location=/usr/bin/fping6
CFG

chown -R zabbix:zabbix /var/lib/zabbix /var/log/zabbix
exec /usr/local/sbin/zabbix_server -f -c /etc/zabbix/zabbix_server.conf

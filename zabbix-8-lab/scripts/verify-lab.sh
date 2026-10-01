#!/usr/bin/env bash
set -euo pipefail

echo '== Containers =='
docker compose ps

echo
echo '== Zabbix version =='
docker compose exec -T zabbix-server /usr/local/sbin/zabbix_server -V | head -n 3

echo
echo '== PostgreSQL =='
docker compose exec -T postgres pg_isready -U "${POSTGRES_USER:-zabbix}" -d "${POSTGRES_DB:-zabbix}"

echo
echo '== ClickHouse Zabbix history tables =='
docker compose exec -T clickhouse clickhouse-client \
  --user "${CLICKHOUSE_USER:-zabbix}" \
  --password "${CLICKHOUSE_PASSWORD:-zabbix}" \
  --query "SHOW TABLES FROM ${CLICKHOUSE_DB:-zabbix} LIKE 'history%'"

echo
echo '== ClickHouse OpenTelemetry tables =='
docker compose exec -T clickhouse clickhouse-client \
  --user "${CLICKHOUSE_USER:-zabbix}" \
  --password "${CLICKHOUSE_PASSWORD:-zabbix}" \
  --query "SHOW TABLES FROM ${CLICKHOUSE_DB:-zabbix} LIKE 'otel_%'"

echo
echo '== OTel Collector health =='
curl -fsS http://127.0.0.1:${OTEL_HEALTH_PORT:-13133}/ && echo

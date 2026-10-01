#!/usr/bin/env bash
set -euo pipefail
: "${ZBX_SERVER_HOST:=zabbix-server}"
: "${ZBX_HOSTNAME:=zabbix-agent2-lab}"

cat >/etc/zabbix/zabbix_agent2.conf <<CFG
LogType=console
Server=${ZBX_SERVER_HOST}
ServerActive=${ZBX_SERVER_HOST}:10051
Hostname=${ZBX_HOSTNAME}
CFG

exec /usr/local/sbin/zabbix_agent2 -f -c /etc/zabbix/zabbix_agent2.conf

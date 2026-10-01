#!/usr/bin/env bash
set -euo pipefail
cat >/etc/zabbix/zabbix_web_service.conf <<CFG
LogType=console
AllowedIP=0.0.0.0/0,::/0
ListenPort=10053
Timeout=30
IgnoreURLCertErrors=1
CFG
exec /usr/local/sbin/zabbix_web_service -c /etc/zabbix/zabbix_web_service.conf

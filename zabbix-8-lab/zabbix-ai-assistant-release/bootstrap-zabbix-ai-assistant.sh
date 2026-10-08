#!/usr/bin/env bash
set -euo pipefail
MODE="${1:---install}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARCHIVE="$HERE/zabbix-ai-assistant-v0.1.0.tar.gz"
[[ -f "$ARCHIVE" ]] || { echo "Arquivo não encontrado: $ARCHIVE" >&2; exit 1; }
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
tar -xzf "$ARCHIVE" -C "$TMP"
exec "$TMP/zabbix-ai-assistant/install-zabbix-ai-assistant.sh" "$MODE"

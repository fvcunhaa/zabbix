# Deploy — Zabbix AI Assistant / Chico v0.1.0

Este pacote contém o módulo frontend, backend FastAPI, governança, integração com o Zabbix MCP Server oficial e o avatar do Chico.

## Deploy

```bash
cd /home/zabbix/zabbix-8-lab/zabbix-ai-assistant-release
chmod +x bootstrap-zabbix-ai-assistant.sh
sudo ./bootstrap-zabbix-ai-assistant.sh --install
sudo ./bootstrap-zabbix-ai-assistant.sh --check
sudo ./bootstrap-zabbix-ai-assistant.sh --deploy-module
```

Depois, no Zabbix:

`Administration → General → Modules → Scan directory → Enable Zabbix AI Assistant`

Em seguida abra:

`Administration → AI Assistant`

Configure o provider (OpenAI ou Anthropic), modelo, preço por 1M tokens para governança de custo e o token global da conta técnica `zabbix-ai`.

O deploy mantém desenvolvimento em `/home/zabbix/zabbix/modules/frontend-dev/zabbix-ai-assistant` e só copia para produção com `--deploy-module`.

## Rollback

```bash
sudo ./bootstrap-zabbix-ai-assistant.sh --rollback
```

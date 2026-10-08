# Zabbix AI Assistant — Chico v0.1.0

Release de deploy do módulo Chico para Zabbix 8.

Inclui:
- Frontend Module nativo do Zabbix com botão flutuante e drawer do Chico.
- Avatar do Chico no launcher, cabeçalho e mensagens.
- Backend FastAPI na rede `zabbix_net`.
- OpenAI + Anthropic.
- Descoberta dinâmica de todas as tools do Zabbix MCP.
- Complemento via Zabbix API para criação/alteração de hosts.
- Token global técnico do Zabbix armazenado criptografado.
- Policy própria por tool: auto / confirmação / bloqueado.
- Banco `zabbix_ai` no PostgreSQL existente.
- Governança de interações, tokens, custos, MCP calls e auditoria.
- Retenção padrão: conversa 30d, metadados 365d, auditoria 365d.

## Deploy

```bash
cd /home/zabbix
git fetch origin
git checkout feature/chico-ai-assistant-v0.1.0

cd zabbix-8-lab/zabbix-ai-assistant-release
chmod +x bootstrap-zabbix-ai-assistant.sh

sudo ./bootstrap-zabbix-ai-assistant.sh --install
sudo ./bootstrap-zabbix-ai-assistant.sh --check
sudo ./bootstrap-zabbix-ai-assistant.sh --deploy-module
```

Depois, no Zabbix:

`Administration → General → Modules → Scan directory → Enable Zabbix AI Assistant`

O instalador **não habilita o módulo automaticamente**.

Depois abra:

`Administration → AI Assistant`

Configure:
1. Provider OpenAI ou Anthropic.
2. Modelo.
3. API Key.
4. Preço de input/output por 1M tokens para governança de custos.
5. Token global do usuário técnico `zabbix-ai`.
6. Policies das tools MCP/API.

## Estrutura instalada

- Backend: `/home/zabbix/zabbix-ai-backend`
- Desenvolvimento do módulo: `/home/zabbix/zabbix/modules/frontend-dev/zabbix-ai-assistant`
- Produção do módulo: `/home/zabbix/zabbix/modules/frontend/zabbix-ai-assistant`
- Backup de módulo: `/home/zabbix/zabbix/modules/backups`

## Rollback

```bash
sudo ./bootstrap-zabbix-ai-assistant.sh --rollback
```

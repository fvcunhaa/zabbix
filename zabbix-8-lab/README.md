# Zabbix 8 Lab — PostgreSQL + ClickHouse + OpenTelemetry

Laboratório Docker para testar o Zabbix 8 a partir do snapshot nightly/RC, com banco relacional em PostgreSQL, history em ClickHouse e pipeline OpenTelemetry usando OTLP.

## Arquitetura

- **Zabbix Server 8.0.0rc1** compilado do snapshot nightly
- **Zabbix Frontend** extraído do mesmo source
- **Zabbix Agent 2** compilado do mesmo source
- **Zabbix Web Service** compilado do mesmo source para reports
- **PostgreSQL 18** para configuração, eventos, inventário e demais dados relacionais
- **ClickHouse 26.4** para history do Zabbix e tabelas `otel_*`
- **OpenTelemetry Collector Contrib** como gateway/proxy OTLP
- **Selenium Chromium** para Browser items

## Source utilizado

Por padrão:

```text
https://cdn.zabbix.com/zabbix/nightly/pre-zabbix-8.0.0rc1-9b7cfbc0cba.tar.gz
```

A URL fica em `.env`, então é possível apontar o lab para outro snapshot nightly.

## Subir o ambiente

```bash
cd zabbix-8-lab
cp .env.example .env
```

Edite pelo menos as senhas em `.env` e depois:

```bash
docker compose build --no-cache
docker compose up -d
```

Acompanhar:

```bash
docker compose ps
docker compose logs -f zabbix-server
docker compose logs -f otel-collector
```

## Acessos

| Serviço | Endpoint |
|---|---|
| Zabbix frontend | `http://HOST:8088` |
| Zabbix server | `HOST:10051` |
| OTLP gRPC | `HOST:4317` |
| OTLP HTTP | `HOST:4318` |
| OTel health | `http://HOST:13133` |
| Selenium | `http://HOST:4444` |
| ClickHouse HTTP | `HOST:8123` |
| ClickHouse Native | `HOST:9000` |

Login inicial do Zabbix:

```text
Admin
zabbix
```

## PostgreSQL x ClickHouse

O PostgreSQL permanece como banco principal do Zabbix. O Server é configurado com `HistoryProvider=clickhouse` para direcionar todos os value types de history para o ClickHouse:

```text
uint,dbl,str,log,text,json
```

As tabelas oficiais de history são criadas com os scripts `database/clickhouse/history_all.sh` do próprio source do Zabbix 8.

O mesmo ClickHouse recebe também dados do OpenTelemetry em tabelas distintas, prefixadas por `otel_`.

## OpenTelemetry

O Collector recebe OTLP em:

```text
gRPC :4317
HTTP :4318
```

E exporta traces, metrics e logs para ClickHouse.

Exemplo de variáveis para uma aplicação instrumentada:

```bash
export OTEL_EXPORTER_OTLP_ENDPOINT=http://SEU_HOST:4318
export OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf
export OTEL_SERVICE_NAME=minha-aplicacao
```

## Browser items

O Zabbix Server usa:

```text
WebDriverURL=http://selenium:4444
StartBrowserPollers=2
```

## Reports

O lab sobe o `zabbix_web_service` e configura o Server com:

```text
WebServiceURL=http://zabbix-web-service:10053/report
StartReportWriters=1
```

## Validação

Depois de subir:

```bash
bash ./scripts/verify-lab.sh
```

Ou manualmente:

```bash
docker compose exec zabbix-server zabbix_server -V
```

```bash
docker compose exec clickhouse clickhouse-client \
  --user zabbix --password 'SUA_SENHA' \
  --query "SHOW TABLES FROM zabbix"
```

## Reset total

> Remove também os volumes do PostgreSQL e ClickHouse.

```bash
docker compose down -v
docker compose up -d --build
```

## Observação

Este projeto utiliza uma versão RC/nightly do Zabbix e foi criado para laboratório, homologação e exploração de recursos do Zabbix 8. Não use este compose como referência direta de produção sem hardening, TLS, secrets e políticas de backup/HA.

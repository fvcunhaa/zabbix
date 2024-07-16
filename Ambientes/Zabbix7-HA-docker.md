# Zabbix 7 em alta disponibilidade com proxy group

Bem-vindo ao repositório onde abordaremos a instalação do Zabbix containerizado em alta disponibilidade. Neste guia, você encontrará as instruções e os arquivos necessários para configurar um ambiente distribuído de alta disponibilidade com Zabbix, utilizando containers Docker.

## Arquitetura do Ambiente

Este setup distribui as aplicações do Zabbix em servidores separados, garantindo uma maior resiliência e performance. A arquitetura é composta por:

Servidor 1: Zabbix Server 01
Servidor 2: Zabbix Server 02 (failover)
Servidor 3: Front-end
Servidor 4: Database
Servidores 5-8: Proxies

Cada aplicação será configurada em containers Docker, com os arquivos docker-compose fornecidos abaixo.

## Composes

## Zabbix Server 01/02

Será apenas um compose do Server, pois você só deve alterar os dados pertinentes, pois o restante é igual.

``` yaml
services:
  zabbix-server:
    container_name: "zabbix-server"
    image: zabbix/zabbix-server-pgsql:7.0-ubuntu-latest
    restart: always
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /etc/timezone:/etc/timezone:ro
    environment:
      ZBX_STARTLLDPROCESSORS: 50
      ZBX_STARTESCALATORS: 10
      ZBX_STARTTIMERS: 3
      ZBX_STARTDBSYNCERS: 10
      ZBX_CACHESIZE: 64M
      ZBX_HISTORYCACHESIZE: 64M
      ZBX_HISTORYINDEXCACHESIZE: 64M
      ZBX_STARTHISTORYPOLLERS: 150
      ZBX_TRENDCACHESIZE: 64M
      ZBX_VALUECACHESIZE: 64M
      ZBX_HOUSEKEEPINGFREQUENCY: 1
      ZBX_MAXHOUSEKEEPERDELETE: 10000
      ZBX_PROBLEMHOUSEKEEPINGFREQUENCY: 60
      DB_SERVER_HOST: "192.168.0.240" # DEVE COLOCAR O IP DO SEU BANCO DE DADOS
      POSTGRES_USER: "zabbix" # USUARIO DO BANCO DE DADOS
      POSTGRES_PASSWORD: "P@ssword" # SENHA DO BANCO DE DADOS
      POSTGRES_DB: "zabbix_db" # NOME DO BANCO DE DADOS
    # ZBX_AUTOHANODENAME=fqdn # Allowed values: fqdn, hostname. Available since                                                                                                                                                              6.0.0
      ZBX_HANODENAME: zbx7-server01 # Available since 6.0.0 ## AQUI VOCE VAI COLOCAR O NOME DO NODE DO HA
    # ZBX_AUTONODEADDRESS=fqdn # Allowed values: fqdn, hostname. Available since                                                                                                                                                              6.0.0
    # ZBX_NODEADDRESSPORT: 10051 # Allowed to use with ZBX_AUTONODEADDRESS varia                                                                                                                                                             ble only. Available since 6.0.0
      ZBX_NODEADDRESS: 192.168.0.235:10051 # Available since 6.0.0 # AQUI VOCE VAI COLOCAR O IP E A PORTA DO NODE DO HA
    network_mode: host
    stop_grace_period: 30s
    labels:
      com.zabbix.description: "Zabbix server with PostgreSQL database support"
      com.zabbix.company: "Zabbix LLC"
      com.zabbix.component: "zabbix-server"
      com.zabbix.dbtype: "pgsql"
      com.zabbix.os: "alpine"
```

## Zabbix Frontend

``` yaml
services:
  zabbix-web-nginx-pgsql:
    container_name: "zabbix-web"
    image: zabbix/zabbix-web-nginx-pgsql:7.0-ubuntu-latest
    restart: always
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /etc/timezone:/etc/timezone:ro
      - ./cert/:/usr/share/zabbix/conf/certs/:ro
    environment:
     # ZBX_SERVER_HOST: ""  # SE FOR USAR HA NAO PRECISA DESSA INFORMACAO
      ZBX_SERVER_NAME: "Zabbix Chico" # NOME QUE DESEJA QUE APARECA NO SEU ZABBIX
      DB_SERVER_HOST: "192.168.0.240" #COLOQUE O IP DO SEU BANCO DE DADOS
      POSTGRES_USER: "zabbix"  # USUARIO DO BANCO DE DADOS
      POSTGRES_PASSWORD: "P@ssword" # SENHA DO BANCO DE DADOS
      POSTGRES_DB: "zabbix_db" # NOME DO BANCO DE DADOS
      ZBX_MEMORYLIMIT: "1024M"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/ping"]
      interval: 10s
      timeout: 5s
      retries: 3
      start_period: 30s
    network_mode: host
    stop_grace_period: 10s
    labels:
      com.zabbix.description: "Zabbix frontend on Nginx web-server with PostgreS                                                                                                                                                             QL database support"
      com.zabbix.company: "Zabbix LLC"
      com.zabbix.component: "zabbix-frontend"
      com.zabbix.webserver: "nginx"
      com.zabbix.dbtype: "pgsql"
      com.zabbix.os: "alpine"
```

## Zabbix Database

``` yaml
services:
  timescale-server:
    container_name: timescaledb
    restart: always
    image: timescale/timescaledb-ha:pg16-all
    environment:
      POSTGRES_USER: "zabbix"  # USUARIO DO BANCO DE DADOS
      POSTGRES_PASSWORD: "P@ssword" # SENHA DO BANCO DE DADOS
      POSTGRES_DB: "zabbix_db" #  NOME DO BANCO DE DADOS
      TS_TUNE_MAX_CONNS: 5000
      TS_TUNE_MAX_BG_WORKERS: 32
    command: postgres -c 'max_connections=5000'
    volumes:
      - timescaledb_data:/home/postgres/pgdata/data
      - ./pg_hba.conf:/etc/postgresql/15/main/pg_hba.conf:ro
    network_mode: host

volumes:
  timescaledb_data:
```

## Zabbix Proxy

Só pegar o mesmo arquivo e colocar nos outros servidores que serão proxy e mudar o nome dos mesmo.

``` yaml
services:
  zabbix-proxy:
    container_name: "zabbix-proxy"
    image: zabbix/zabbix-proxy-sqlite3:7.0-ubuntu-latest
    pull_policy: always
    environment:
      - ZBX_PROXYMODE=0  # 0 - active proxy and 1 - passive proxy
      - ZBX_SERVER_HOST=192.168.0.235;192.168.0.236 #IP DOS ZABBIX SERVER
      - ZBX_SERVER_PORT=10051 #PORTA UTILIZADA 
      - ZBX_HOSTNAME=zbx7-proxy01 #NOME DO SEU PROXY
      - ZBX_DEBUGLEVEL=3  # 0 - basic info, 1 - critical, 2 - error, 3 - warning                                                                                                                                                             s, 4 - for debugging, 5 - extended debugging
      - ZBX_ENABLEREMOTECOMMANDS=1
      - ZBX_PROXYLOCALBUFFER=0  # mantém cópia dos eventos mesmo depois de envia                                                                                                                                                             r ao server (valor em horas)
      - ZBX_PROXYOFFLINEBUFFER=1  # 6 horas
      - ZBX_PROXYHEARTBEATFREQUENCY=60  # 60 seg
      - ZBX_PROXYCONFIGFREQUENCY=200
      - ZBX_DATASENDERFREQUENCY=1  # 1 Seg
      - ZBX_STARTHISTORYPOLLERS=2  # ----------------
      - ZBX_STARTPOLLERS=10 #500
      - ZBX_STARTPREPROCESSORS=20 #500
      - ZBX_STARTPOLLERSUNREACHABLE=10   #300
      - ZBX_STARTPINGERS=10  #100
      - ZBX_STARTDISCOVERERS=5
      - ZBX_STARTHTTPPOLLERS=5
      - ZBX_HOUSEKEEPINGFREQUENCY=1
      - ZBX_STARTVMWARECOLLECTORS=1
      - ZBX_VMWAREFREQUENCY=60
      - ZBX_VMWAREPERFFREQUENCY=60
      - ZBX_VMWARECACHESIZE=32M
      - ZBX_VMWARETIMEOUT=300
      - ZBX_CACHESIZE=32M
      - ZBX_STARTDBSYNCERS=10 #20
      - ZBX_HISTORYCACHESIZE=32M
      - ZBX_HISTORYINDEXCACHESIZE=32M
      - ZBX_TIMEOUT=30  # 30 Seg
      - ZBX_UNREACHABLEPERIOD=10
      - ZBX_UNAVAILABLEDELAY=10
      - ZBX_UNREACHABLEDELAY=10
      - ZBX_LOGSLOWQUERIES=3000
      - ZBX_STATSALLOWEDIP=127.0.0.1
      - ZBX_TLSCONNECT=psk
      - ZBX_TLSACCEPT=psk
      - ZBX_TLSPSKIDENTITY=zbx7-proxy01 #NOME DO SEU PROXY, EU GOSTO DE UTILIZAR NO IDENTIFICAR DE PSK DO PROXY
      - ZBX_TLSPSKFILE=zabbix_proxy.psk
    restart: always
    network_mode: host
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /zabbix-proxy/usr/lib/zabbix/alertscripts:/usr/lib/zabbix/alertscripts:r                                                                                                                                                             o
      - /zabbix-proxy/usr/lib/zabbix/externalscripts:/usr/lib/zabbix/externalscr                                                                                                                                                             ipts:ro
      - /zabbix-proxy/var/lib/zabbix/enc:/var/lib/zabbix/enc:ro
      - /zabbix-proxy/var/lib/zabbix/mibs:/var/lib/zabbix/mibs:ro
```

Todas as máquinas tem que estar com docker instalado.

### Os três primeiros comando é para instalar o docker e update do SO
sudo curl -fsSL https://get.docker.com -o get-docker.sh

sudo sh get-docker.sh

sudo apt update

### Após isso recomendo criar uma pasta.
sudo mkdir -p /home/zabbix/

### Depois tu vai entrar na pasta e colocar o docker compose, lembrando que deve salvar da seguinte maneira.

docker-compose.yaml

### Após isso é apenas usar o comando para baixar as imagens e subir os container.

sudo docker compose up -d

### Para ver ps containers rodando, deve utilizar o comando 

docker ps

## Como Contribuir

Se você tem algo para contribuir, como novos templates, scripts ou guias de configuração, fique à vontade para enviar uma solicitação de pull. Contribuições são bem-vindas e apreciadas!

## Licença

Este repositório é fornecido sob a [Licença MIT](LICENSE). Sinta-se à vontade para usar, modificar e distribuir o conteúdo conforme necessário.

## Contato

Para perguntas, sugestões ou apenas para dizer olá, você pode entrar em contato com os mantenedores deste repositório através das issues ou por e-mail em fvcunhaa@gmail.com.

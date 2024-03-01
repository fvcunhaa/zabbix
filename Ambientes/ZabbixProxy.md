# Zabbix Proxy

O Zabbix Proxy é um intermediário entre os agentes e o servidor Zabbix. Ele coleta dados de hosts remotos e os envia para o servidor Zabbix, permitindo monitoramento distribuído e reduzindo a carga de trabalho nos servidores principais.

https://www.zabbix.com/documentation/current/en/manual/concepts/proxy

## Sobre o Zabbix Proxy em container

Você pode implantar facilmente um Zabbix Proxy usando o Docker Compose. Aqui está um exemplo de arquivo `docker-compose.yml` para iniciar um Zabbix Proxy junto com um banco de dados SQLite.

``` yaml
version: '3.8'
services:
  zabbix-proxy:
    container_name: "zbx-proxy"
    image: zabbix/zabbix-proxy-sqlite3:6.4.4-ubuntu
    user: root
    environment:
      - ZBX_PROXYMODE=0  # 0 - active proxy and 1 - passive proxy
      - ZBX_SERVER_HOST=      # IP OU DNS DO SEU ZABBIX SERVER
      - ZBX_SERVER_PORT=10051
      - ZBX_HOSTNAME=prx-teste
      - ZBX_DEBUGLEVEL=3  # 0 - basic info, 1 - critical, 2 - error, 3 - warnings, 4 - for debugging, 5 - extended debugging
      - ZBX_ENABLEREMOTECOMMANDS=1
      - ZBX_PROXYLOCALBUFFER=0  # mantém cópia dos eventos mesmo depois de enviar ao server (valor em horas)
      - ZBX_PROXYOFFLINEBUFFER=1  # 6 horas
      - ZBX_PROXYHEARTBEATFREQUENCY=60  # 60 seg
      - ZBX_CONFIGFREQUENCY=300  # 300 Seg
      - ZBX_DATASENDERFREQUENCY=1  # 1 Seg
      - ZBX_STARTHISTORYPOLLERS=3  # ----------------
      - ZBX_STARTPOLLERS=5 #500 
      - ZBX_STARTPREPROCESSORS=5 #500
      - ZBX_STARTPOLLERSUNREACHABLE=30   #300
      - ZBX_STARTPINGERS=5  #100
      - ZBX_STARTDISCOVERERS=3
      - ZBX_STARTHTTPPOLLERS=5
      - ZBX_HOUSEKEEPINGFREQUENCY=1
      - ZBX_STARTVMWARECOLLECTORS=1
      - ZBX_CACHESIZE=128M
      - ZBX_STARTDBSYNCERS=20 #20
      - ZBX_HISTORYCACHESIZE=256M
      - ZBX_HISTORYINDEXCACHESIZE=256M
      - ZBX_TIMEOUT=30  # 30 Seg
      - ZBX_UNREACHABLEPERIOD=400
      - ZBX_UNAVAILABLEDELAY=400
      - ZBX_UNREACHABLEDELAY=400
      - ZBX_LOGSLOWQUERIES=3000
      - ZBX_STATSALLOWEDIP=127.0.0.1
      - ZBX_TLSCONNECT=psk
      - ZBX_TLSACCEPT=psk
      - ZBX_TLSPSKIDENTITY=prx-teste
      - ZBX_TLSPSKFILE=zabbix_proxy.psk
    restart: always
    volumes:
       - /etc/localtime:/etc/localtime:ro
       - /zabbix-proxy/usr/lib/zabbix/alertscripts:/usr/lib/zabbix/alertscripts    
       - /zabbix-proxy/usr/lib/zabbix/externalscripts:/usr/lib/zabbix/externalscripts
       - /zabbix-proxy/var/lib/zabbix/enc:/var/lib/zabbix/enc
       - /zabbix-proxy/var/lib/zabbix/mibs:/var/lib/zabbix/mibs
```
## Como Utilizar
Você deve salvar o arquivo docker-compose.yaml no diretorio desejado e após isso execute os passos abaixo.

```sh
# Criar caminho para a chave de criptografia
mkdir -p /zabbix-proxy/var/lib/zabbix/enc/

# Criar chave de criptografia
openssl rand -hex 32

# Irá ter um output igual ao que irei mostra abaixo
4de971867cff20facd8a49242bd3ebddaf872271dccc49b530ccc325cd7d05a3

# Você deve salvar essa chave no arquivo zabbix_proxy.psk
nano /zabbix-proxy/var/lib/zabbix/enc/zabbix_proxy.psk

# Apos salvar a chave dentro do arquivo você deve dar permissão
sudo chmod 775 /zabbix-proxy/var/lib/zabbix/enc/zabbix_proxy.psk

# Agora será o comando para subir o container do proxy
docker compose up -d

# Para ver o container basta dar o comando
docker ps

# Para verificar os logs basta dar o comando abaixo
docker logs nomedocontainer
```

## Como Contribuir

Se você tem algo para contribuir, como novos templates, scripts ou guias de configuração, fique à vontade para enviar uma solicitação de pull. Contribuições são bem-vindas e apreciadas!

## Licença

Este repositório é fornecido sob a [Licença MIT](LICENSE). Sinta-se à vontade para usar, modificar e distribuir o conteúdo conforme necessário.

## Contato

Para perguntas, sugestões ou apenas para dizer olá, você pode entrar em contato com os mantenedores deste repositório através das issues ou por e-mail em fvcunhaa@gmail.com.

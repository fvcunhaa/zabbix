# Script em Shell Automatizando Zabbix Proxy em Container

Esse script ele instala o docker, depois cria o diretório conforme o padrão que realizo em produção, logo após isso ele cria o docker-compose.yaml e lembrando que tem campos no arquivo do docker compose que devem ser preenchido de acordo com seu ambiente, tais como:

ZBX_SERVER_HOST= Colocar o IP ou DNS do seu Zabbix

ZBX_HOSTNAME= Nome do seu Proxy

ZBX_TLSPSKIDENTITY= Por padrão coloco o mesmo nome do proxy

Você deve salvar esse Script que está abaixo com o nome que desejar, recomendo como zabbixproxy.sh pois é em shellscript e não pode esquecer o ".sh", você deve dar permissão a esse script.

## Comando para criar o arquivo

```sh
nano zabbixproxy.sh
```
## Comando para dar permissão ao script

```sh
chmod +x nomedoscript
```

# Abaixo conteúdo do script

```sh
#!/bin/bash

# Os três primeiros comando é para instalar o docker e update do SO
sudo curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo apt update

# Esse comando serve para criar o diretório onde irá ficar o docker-compose.yamlS
sudo mkdir -p /home/zabbix-proxy/

# Agora é a criação do arquivo docker-compose.yaml
cat <<EOF > /home/zabbix-proxy/docker-compose.yaml
services:
  zabbix-proxy:
    container_name: "zbx-proxy"
    image: zabbix/zabbix-proxy-sqlite3:7.4.2-alpine
    user: root
    environment:
      - ZBX_PROXYMODE=0  # 0 - active proxy and 1 - passive proxy
      - ZBX_SERVER_HOST= 
      - ZBX_SERVER_PORT=10051
      - ZBX_HOSTNAME=prx-teste
      - ZBX_DEBUGLEVEL=3  # 0 - basic info, 1 - critical, 2 - error, 3 - warnings, 4 - for debugging, 5 - extended debugging
      - ZBX_ENABLEREMOTECOMMANDS=1
      - ZBX_PROXYLOCALBUFFER=0 
      - ZBX_PROXYOFFLINEBUFFER=4 
      - ZBX_PROXYHEARTBEATFREQUENCY=60  
      - ZBX_CONFIGFREQUENCY=300  
      - ZBX_DATASENDERFREQUENCY=1 
      - ZBX_STARTHISTORYPOLLERS=3  
      - ZBX_STARTPOLLERS=5
      - ZBX_STARTPREPROCESSORS=5 
      - ZBX_STARTPOLLERSUNREACHABLE=5  
      - ZBX_STARTPINGERS=5  
      - ZBX_STARTDISCOVERERS=3
      - ZBX_STARTHTTPPOLLERS=5
      - ZBX_HOUSEKEEPINGFREQUENCY=1
      - ZBX_STARTVMWARECOLLECTORS=1
      - ZBX_CACHESIZE=8M
      - ZBX_STARTDBSYNCERS=4
      - ZBX_HISTORYCACHESIZE=16M
      - ZBX_HISTORYINDEXCACHESIZE=4M
      - ZBX_TIMEOUT=10 # 
      - ZBX_UNREACHABLEPERIOD=45
      - ZBX_UNAVAILABLEDELAY=60
      - ZBX_UNREACHABLEDELAY=15
      - ZBX_LOGSLOWQUERIES=3000
      - ZBX_STATSALLOWEDIP=127.0.0.1
      - ZBX_TLSCONNECT=psk
      - ZBX_TLSACCEPT=psk
      - ZBX_TLSPSKIDENTITY=prx-teste
      - ZBX_TLSPSKFILE=/var/lib/zabbix/enc/zabbix_proxy.psk
    restart: always
    volumes:
       - /etc/localtime:/etc/localtime:ro
       - /zabbix-proxy/usr/lib/zabbix/alertscripts:/usr/lib/zabbix/alertscripts    
       - /zabbix-proxy/usr/lib/zabbix/externalscripts:/usr/lib/zabbix/externalscripts
       - /zabbix-proxy/var/lib/zabbix/enc:/var/lib/zabbix/enc
       - /zabbix-proxy/var/lib/zabbix/mibs:/var/lib/zabbix/mibs
EOF

# Então devemos criar o diretório onde irá ficar a nossa chave de criptografia
sudo mkdir -p /zabbix-proxy/var/lib/zabbix/enc

# Aqui irá criar o arquivo que contém a chave de criptografia. 
# Lembrando que essa chave deve ser gerada, essa é apenas para teste mas irá funcionar no seu laboratório, você deve colocar ela lá no front-end do zabbix quando for cadastrar um novo proxy
cat <<EOF > /zabbix-proxy/var/lib/zabbix/enc/zabbix_proxy.psk
4de971867cff20facd8a49242bd3ebddaf872271dccc49b530ccc325cd7d05a3
EOF

# Esse comando é para da a devida permissão ao arquivo
sudo chmod 775 /zabbix-proxy/var/lib/zabbix/enc/zabbix_proxy.psk

# Agora irá para o diretório e dar o comando para criar os container
cd /home/zabbix-proxy/

# Esse comando serve para criar os container
sudo docker compose up -d

# Esse comando serve para ver o container
sudo docker ps

# Se for necessário ver os logs basta dar o comando baixo
sudo docker logs nomedocontainer
``````

## Como Contribuir

Se você tem algo para contribuir, como novos templates, scripts ou guias de configuração, fique à vontade para enviar uma solicitação de pull. Contribuições são bem-vindas e apreciadas!

## Licença

Este repositório é fornecido sob a [Licença MIT](LICENSE). Sinta-se à vontade para usar, modificar e distribuir o conteúdo conforme necessário.

## Contato

Para perguntas, sugestões ou apenas para dizer olá, você pode entrar em contato com os mantenedores deste repositório através das issues ou por e-mail em fvcunhaa@gmail.com.

## Guia: Certificados TLS para Zabbix (CA, Server e Agents)


> Este passo a passo mostra como criar a **CA**, gerar os **certificados do servidor e dos agentes**, definir permissões/pastas e **configurar** os arquivos do Zabbix.



## 1) Criar a CA

```bash
# Criar diretório
sudo mkdir -p /home/zabbix/ssl

# Gerar chave privada da CA (4096 bits)
openssl genrsa -out zabbix-ca.key 4096

# Emitir certificado da CA (válido por 3 anos)
openssl req -x509 -new -key zabbix-ca.key -sha256 -days 1095 -out zabbix-ca.crt   -subj "/CN=CA-FIEP-ZABBIX"
```

- O `zabbix-ca.crt` será distribuído ao **servidor** e a **todos os agentes** para validar os certificados apresentados pelos pares.



## 2) Extensões TLS (arquivo `zbx.ext`)

```bash
cat > zbx.ext <<'EOF'
keyUsage=critical,digitalSignature,keyEncipherment
extendedKeyUsage=serverAuth,clientAuth
EOF
```

- `keyUsage`: define operações permitidas (assinatura digital e troca de chaves).  
- `extendedKeyUsage`: permite uso como **servidor** e **cliente** TLS.


## 3) Certificado do Servidor

```bash
# Chave do servidor
openssl genrsa -out server.key 2048

# CSR do servidor
openssl req -new -key server.key -out server.csr   -subj "/CN=CA-ZABBIX"

# Assinar certificado do servidor com a CA
openssl x509 -req -in server.csr -CA zabbix-ca.crt -CAkey zabbix-ca.key -CAcreateserial   -out server.crt -days 1095 -sha256 -extfile zbx.ext
```

**Resultado:**
- `server.crt` — certificado público do servidor  
- `server.key` — chave privada do servidor  


## 4) Certificados dos Agentes (certificado único)

```bash
# Chave do agente
openssl genrsa -out agente.key 2048

# CSR do agente
openssl req -new -key agente.key -out agente.csr   -subj "/CN=CA-AGENTE"

# Assinar certificado do agente com a CA
openssl x509 -req -in agente.csr -CA zabbix-ca.crt -CAkey zabbix-ca.key -CAcreateserial   -out agente.crt -days 1095 -sha256 -extfile zbx.ext
```

**Resultado:**
- `agente.crt` — certificado único para todos os agentes  
- `agente.key` — chave privada única compartilhada entre todos os agentes  

> ⚠️ Nota: usar certificado único simplifica a gestão, mas aumenta o risco. Em ambientes críticos, prefira **um par de chave/certificado por agente**.



## 5) Permissões e Diretórios

```bash
# Ajustar permissões
sudo chown -R zabbix:zabbix /home/zabbix/ssl
sudo chmod 700 /home/zabbix/ssl
```



## 6) Configuração do Zabbix Server

**Arquivos necessários em `/home/zabbix/ssl`:**
- `zabbix-ca.crt`  
- `server.crt`  
- `server.key`

**Editar `/etc/zabbix/zabbix_server.conf`:**

```ini
TLSCAFile=/home/zabbix/ssl/zabbix-ca.crt
TLSCertFile=/home/zabbix/ssl/server.crt
TLSKeyFile=/home/zabbix/ssl/server.key
```


## 7) Configuração do Zabbix Agent (Linux)

Obs.: Você deve criar a pasta aonde irá ficar os certificados:

```bash
# Criar diretório
sudo mkdir -p /home/zabbix/ssl
```

**Arquivos necessários em `/home/zabbix/ssl`:**
- `zabbix-ca.crt`  
- `agente.crt`  
- `agente.key`

**Editar `/etc/zabbix/zabbix_agentd.conf` (ou `zabbix_agent2.conf`):**

```ini
TLSConnect=cert
TLSAccept=cert

TLSCAFile=/home/zabbix/ssl/zabbix-ca.crt
TLSCertFile=/home/zabbix/ssl/agente.crt
TLSKeyFile=/home/zabbix/ssl/agente.key

# Pinagem do servidor
TLSServerCertIssuer=CN=CA-ZABBIX
TLSServerCertSubject=CN=CA-ZABBIX
```
## 8) Configuração do Zabbix Agent (Windows)

Obs.: Você deve criar a pasta aonde irá ficar os certificados:

Você irá criar dentro da pasta do Zabbix Agent a pasta SSL
```ini
C:\Program Files\Zabbix Agent 2\ssl
```
<img width="691" height="144" alt="image" src="https://github.com/user-attachments/assets/b157e313-3efc-4b7e-b2f0-6e3c8946b0fa" />


**Arquivos necessários em `C:\Program Files\Zabbix Agent 2\ssl`:**
- `zabbix-ca.crt`  
- `agente.crt`  
- `agente.key`

**Editar `C:\Program Files\Zabbix Agent 2\zabbix_agent2.conf` (ou `zabbix_agentd.conf`):**

```ini
TLSConnect=cert
TLSAccept=cert

TLSCAFile=C:\Program Files\Zabbix Agent 2\ssl\zabbix-ca.crt
TLSCertFile=C:\Program Files\Zabbix Agent 2\ssl\agente.crt
TLSKeyFile=C:\Program Files\Zabbix Agent 2\ssl\agente.key

# Pinagem do servidor
TLSServerCertIssuer=CN=CA-ZABBIX
TLSServerCertSubject=CN=CA-ZABBIX
```
## 9) Cadastro de Hosts no Frontend do Zabbix com TLS/Certificados

Depois de gerar e configurar os certificados no **servidor** e nos **agentes**, é necessário ajustar o **frontend do Zabbix** para que a comunicação TLS com certificado funcione corretamente.



## 9.1) Acessar o Frontend
- Entre no **Zabbix Frontend** pelo navegador.
- Vá em: **Data collection → Hosts → [Escolha o host] → Encryption**.
  
<img width="888" height="373" alt="image" src="https://github.com/user-attachments/assets/e682986f-ccf3-46b1-9775-744cb380e478" />

<img width="1051" height="336" alt="image" src="https://github.com/user-attachments/assets/5bfa80df-9ff5-442e-80dc-97b34b692ba7" />


## 9.2) Parâmetros de Validação
Preencha os campos de acordo com a CA criada:

- **Issuer**: `CN=CA-ZABBIX`
- **Subject**: `CN=CA-ZABBIX`

Esses valores devem coincidir exatamente com os configurados nos certificados e no `zabbix_agentd.conf` para que a pinagem funcione corretamente.

Irá ficar com o encryption verdinho no front-end se as configurações ficaram corretas.
<img width="1550" height="38" alt="image" src="https://github.com/user-attachments/assets/68e15ddb-da25-4b7c-8292-0548e1c4c37e" />


## 10) Reiniciar Serviços

```bash
# Reiniciar servidor
sudo systemctl restart zabbix-server

# Reiniciar agente(s)
sudo systemctl restart zabbix-agent    # ou zabbix-agent2
```


## 11) Resumo dos Arquivos

- **CA (para todos):** `zabbix-ca.crt`  
- **Servidor:** `server.crt`, `server.key`  
- **Agentes (modelo único):** `agente.crt`, `agente.key`  

# Script em PowerShell Automatizando Adição de Hosts

Este script foi criado para adicionar hosts em massa a um grupo específico via API, utilizando PowerShell. Ele foi desenvolvido para evitar a adição manual de mais de 800 hosts. Como era um ambiente que não possuía acesso externo e não havia Python instalado nas máquinas, desenvolvi esse script para atender às demandas e otimizar as tarefas diárias deste projeto em particular.


# Abaixo conteúdo do script

```ps
﻿# Parâmetros Zabbix API
$zabbixURL = "https://Seu_Dominio/api_jsonrpc.php"
$authToken = "Seu_token"  # Token de autenticação da API do Zabbix

# Função para chamar a API do Zabbix
function Invoke-ZabbixAPI {
    param (
        [string]$method,
        [hashtable]$params
    )
    $body = @{
        jsonrpc = "2.0"
        method  = $method
        params  = $params
        auth    = $authToken
        id      = 1
    }
    try {
        return Invoke-RestMethod -Uri $zabbixURL -Method Post -Body ($body | ConvertTo-Json -Depth 10) -ContentType "application/json"
    } catch {
        return $null
    }
}

# Função para obter o ID do grupo pelo nome
function Get-GroupIdByName {
    param (
        [string]$groupName
    )
    $params = @{
        filter = @{}
    }
    $response = Invoke-ZabbixAPI -method "hostgroup.get" -params $params
    if ($response -and $response.result) {
        $group = $response.result | Where-Object { $_.name -eq $groupName }
        return $group.groupid
    }
    return $null
}

# Lista de Hosts (Nome, IP e Grupo)
$hostsData = @(
    @{ Nome = "Host1"; IP = "192.168.1.1"; Grupo = "Virtual machines" },
    @{ Nome = "Host2"; IP = "192.168.1.2"; Grupo = "Virtual machines" },
    @{ Nome = "Host3"; IP = "192.168.1.3"; Grupo = "Virtual machines" }
)

# Loop sobre a lista de hosts
foreach ($currentHost in $hostsData) {
    $hostName = $currentHost.Nome
    $hostIP = $currentHost.IP
    $groupName = $currentHost.Grupo
    $groupId = Get-GroupIdByName -groupName $groupName

    if ($null -ne $groupId) {
        # Parâmetros para adicionar o host
        $params = @{
            host = $hostName
            interfaces = @(
                @{
                    type = 1  # 1 = agente Zabbix
                    main = 1
                    useip = 1
                    ip = $hostIP
                    dns = ""
                    port = "10050"  # Porta padrão do agente Zabbix
                }
            )
            groups = @(
                @{
                    groupid = $groupId
                }
            )
            inventory_mode = 0  # Desativar inventário automático
        }

        # Chama a API para criar o host
        $response = Invoke-ZabbixAPI -method "host.create" -params $params

        # Verifica a resposta
        if ($response -and $response.result) {
            # Sucesso, você pode adicionar um log aqui se precisar
        }
    }
}
``````

## Como Contribuir

Se você tem algo para contribuir, como novos templates, scripts ou guias de configuração, fique à vontade para enviar uma solicitação de pull. Contribuições são bem-vindas e apreciadas!

## Licença

Este repositório é fornecido sob a [Licença MIT](LICENSE). Sinta-se à vontade para usar, modificar e distribuir o conteúdo conforme necessário.

## Contato

Para perguntas, sugestões ou apenas para dizer olá, você pode entrar em contato com os mantenedores deste repositório através das issues ou por e-mail em fvcunhaa@gmail.com.

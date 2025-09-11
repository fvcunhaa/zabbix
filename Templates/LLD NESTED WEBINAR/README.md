# Webinar: Nested LLD no Zabbix 7.4

Este repositório contém o material apresentado no nosso **webinar sobre Nested LLD (Low-Level Discovery) no Zabbix 7.4**, com foco em ambientes Kubernetes.

##  O que é LLD?
O **Low-Level Discovery (LLD)** é um recurso do Zabbix que permite descobrir e monitorar automaticamente entidades dinâmicas, como:
- Interfaces de rede  
- Discos  
- Containers e pods em Kubernetes  

Com o LLD, evitamos a configuração manual repetitiva e garantimos que o ambiente seja acompanhado em tempo real.

---

##  Tipos de LLD abordados
Durante o webinar, exploramos as diferenças entre:

###  LLD com Host Prototype (método tradicional)
- Cada entidade descoberta gera um **novo host**.  
- Escalabilidade existe, mas **sem hierarquia** → clusters grandes geram uma explosão de hosts independentes.  
- Útil para inventário e monitoramento isolado de dispositivos/VMs.  

###  LLD Nested (Aninhada) – novidade no Zabbix 7.4
- Permite descoberta **hierárquica**:  
  `Cluster → Namespace → Pod → Container → Métricas`  
- Mais fiel à estrutura de ambientes modernos (Kubernetes, cloud, containers).  
- Evita explosão de hosts → tudo fica organizado em uma árvore dentro do mesmo contexto.  

---

##  Comparativo

| Aspecto                  | LLD com Host Prototype | LLD Nested (Aninhado) |
|---------------------------|------------------------|------------------------|
| Estrutura                | Cada entidade vira host separado | Descoberta hierárquica dentro do mesmo host |
| Hierarquia               | Não mantém relação entre entidades | Mantém a relação (cluster → ns → pod → container) |
| Escalabilidade           | Muitos hosts independentes | Mais eficiente e organizada |
| Casos de uso típicos      | Inventário de dispositivos, VMs | Kubernetes, cloud, containers |
| Complexidade de configuração | Mais simples (consolidado) | Recurso novo, exige planejamento |

---

##  Exemplo prático
No webinar mostramos um caso com:
- **1 Cluster** (master e worker)  
- **2 Namespaces** (produção e homologação)  
- **Pods com 2 containers** cada  
- Métricas coletadas: **CPU (%)** e **Memória (%)**  

O JSON com os dados de exemplo usados está disponível neste repositório em:  
👉 [`TEMPLATE NESTED LLD - WEBINAR 11-09-2025.json`]

---

##  Conclusão
- O **LLD tradicional** continua útil em cenários clássicos.  
- O **Nested LLD** é a evolução necessária para ambientes modernos, garantindo **hierarquia, organização e eficiência**.  
- A escolha depende do caso de uso, mas para Kubernetes o **nested** é altamente recomendado.

---

 **Referência:** [Documentação oficial do Zabbix 7.4]([https://www.zabbix.com/documentation/current/en/manual/discovery/low_level_discovery/nested](https://www.zabbix.com/documentation/7.4/en/manual/discovery/low_level_discovery/discovery_prototypes?hl=LLD%2Cnested%2CNested))


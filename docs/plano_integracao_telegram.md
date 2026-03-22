# Plano de Implementação: Integração Telegram -> Chatwoot (Visitas)

Este documento detalha a sequência de comunicação e os componentes técnicos para permitir o cadastro de visitas na ficha da empresa via Telegram, com validação de agente.

## 1. Sequência de Comunicação (Fluxo no Telegram)

O bot seguirá esta sequência lógica:

1.  **Início**: Usuário envia `/visita`.
2.  **Validação de Agente**:
    - O sistema verifica se o **ID do Telegram** já está vinculado a um e-mail de agente.
    - **Se não estiver vinculado**:
        - *Bot*: "Para iniciar, informe seu e-mail de agente do Chatwoot."
        - *Usuário*: Envia o e-mail.
        - *Ação*: O sistema valida se o e-mail pertence a um agente ativo. Se sim, vincula o ID do Telegram ao agente. Caso contrário, retorna "Acesso não permitido para enviar visitas".
3.  **Busca de Empresa**:
    - *Bot*: "Qual o nome da empresa que deseja cadastrar a visita?"
    - *Usuário*: Digita o nome.
    - *Ação*: Bot consulta API e retorna botões com os resultados.
4.  **Seleção e Responsável**:
    - Usuário seleciona a empresa.
    - *Bot*: "Quem é o responsável por esta ficha?"
    - *Usuário*: Digita o nome.
5.  **Tipo de Serviço**:
    - *Bot*: "Selecione o tipo de serviço:" (Botões: [Treinamento, Implantação, Sistema, Hardware, Rede]).
6.  **Descrição**:
    - *Bot*: "Descreva o serviço realizado."
    - *Usuário*: Envia texto.
7.  **Finalização**:
    - *Bot*: "Visita registrada com sucesso na ficha do cliente!"
    - *Ação*: Salva os dados na "aba" correspondente ao serviço.

---

## 2. Implementação Técnica

### A. Backend (MenuPdvDmais)

#### [NEW] Model `TelegramAgent`
- Tabela para mapear `telegram_user_id` para `user_id` (agente).
- Local: `MenuPdvDmais/enterprise/app/models/telegram_agent.rb`.

#### [NEW] `CompaniesController`
- **`validate_agent`**: Recebe e-mail e ID Telegram, valida e salva vínculo.
- **`register_visit`**: 
  - Recebe: `company_id`, `responsavel`, `tipo_servico`, `descricao`.
  - Salva a data/hora e os dados na tabela respectiva ao tipo de serviço (ex: `DeploymentTraining`, `DeploymentSystem`, etc).
  - Bloqueia requisições que não venham do bot (validação via User-Agent ou Token específico).

#### Armazenamento na Ficha
- Os dados serão exibidos na "Ficha do Cliente" em abas separadas por tipo de serviço.
- Registro inclui: Data/Hora, Nome do Serviço, Agente, Empresa (Responsável) e Resumo da descrição.
- **Observação**: Remoção de abas "Agenda" e "Histórico" conforme solicitado, unificando a visualização.

### B. Lógica do Bot (Agent Bot Webhook)
- Gerencia o estado (Step 1: Email, Step 2: Empresa...).
- Vincula o número do Telegram ao agente no primeiro uso.
- Limita o acesso apenas a e-mails de agentes válidos.

---

## 3. Regras de Negócio e Segurança
1.  **Bloqueio Desktop**: O cadastro de fichas de visita deve ser bloqueado via interface web, permitindo apenas via API/Telegram.
2.  **Validação de Agente**: Mensagem de "Não permitido" caso o e-mail informado não seja de um agente.
3.  **Histórico**: O histórico da conversa no Telegram servirá como o próprio histórico/resumo da visita.

---

## 4. Plano de Verificação
1.  **Vínculo**: Testar informar e-mail válido/inválido e ver se o ID Telegram é salvo.
2.  **Abas**: Criar uma visita de cada tipo e verificar se aparecem nas abas corretas na UI do Chatwoot.
3.  **Segurança**: Tentar acessar o endpoint via navegador e confirmar o bloqueio.

---

## 5. Ativação e Configuração

Para ativar o bot e conectar ao Chatwoot no domínio de produção:

1.  **URL de Webhook**: `https://erpchat.pdvdmais.com.br/enterprise/api/v1/accounts/1/telegram/webhook`
2.  **Comando de Ativação**:
    Execute via `curl` para registrar o webhook no Telegram:
    ```bash
    curl -X POST "https://api.telegram.org/bot8763085841:AAE9ESml0I2BF6sgFmWBQ18aGoZjfGmLHgc/setWebhook?url=https://erpchat.pdvdmais.com.br/enterprise/api/v1/accounts/1/telegram/webhook"
    ```
    *(Substitua `1` pelo ID da conta correta e `<SEU_TOKEN>` pelo token do BotFather)*

3.  **Ambiente**:
    Certifique-se de que a variável `TELEGRAM_BOT_TOKEN` está configurada no `.env` do servidor.
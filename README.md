# ErpChatwoot (Wrapper Deploy)

Este repositório contém a estratégia de deploy "Wrapper" para o Chatwoot customizado (**MenuPdvDmais Enterprise**).
Ele combina a estabilidade do `chatwoot-base` (upstream) com um conjunto poderoso de extensões proprietárias via Docker.

## 🚀 Funcionalidades Adicionais (Menu Enterprise)

O projeto inclui o módulo `MenuPdvDmais`, que expande o Chatwoot com 3 novos menus laterais totalmente integrados e personalizáveis:

1.  **💰 Financeiro (Iframe):**
    *   Integração visual de telas financeiras externas.
    *   Permite carregar seus painéis de gestão dentro da interface do Chatwoot.

2.  **📋 Kanban Personalizável:**
    *   Organize conversas e tarefas em colunas arrastáveis (Drag-and-Drop).
    *   Fluxos de trabalho visuais para equipes de vendas e suporte.

3.  **🏢 Gestão de Contatos (Agrupamento):**
    *   Visualização avançada de contatos.
    *   Agrupamento inteligente por empresa/organização.

> **Nota para Desenvolvedores:** Todos os menus foram projetados para serem **facilmente editáveis**. Você pode renomear, adicionar ícones ou alterar a lógica dos menus diretamente na pasta `MenuPdvDmais/enterprise`, sem precisar fazer fork do core do Chatwoot.

## Estrutura

-   **`Dockerfile`**: Multistage build que clona dependências, copia o `chatwoot-base` e aplica os arquivos do `MenuPdvDmais` por cima.
-   **`docker-compose.yaml`**: Orquestração de produção com Postgres (pgvector), Redis e Sidekiq.
-   **`deploy.sh`**: Script utilitário para commitar e fazer deploy.
-   **`update_upstream.sh`**: Script para atualizar a base do Chatwoot.
-   **`.env`**: Configurações sensíveis (NÃO commitar). Use `.env.example` como base.

## Como Fazer Deploy

1.  **Configurar Variáveis:**
    Copie o exemplo e ajuste as senhas:
    ```bash
    cp .env.example .env
    ```bash
    cp .env.example .env
    # Edite POSTGRES_PASSWORD, REDIS_PASSWORD, etc.
    # IMPORTANTE: Defina SECRET_KEY_BASE (gere com `openssl rand -hex 64`)
    ```
    > **No Coolify:** Vá em "Environment Variables" e adicione `SECRET_KEY_BASE` com um valor longo e aleatório.

2.  **Iniciar (Primeira Vez):**
    ```bash
    ./deploy.sh
    # OU
    docker-compose up -d --build
    ```

3.  **Banco de Dados:**
    O banco é inicializado automaticamente no boot do container.

## 🔄 Como Atualizar (Update Stream)

Para manter seu Chatwoot atualizado com a versão mais recente oficial:

1.  **Atualizar Base:**
    ```bash
    ./update_upstream.sh
    ```
    *Isso baixa a última versão stable do repo oficial e atualiza a pasta `chatwoot-base`.*

2.  **Commitar e Deploy:**
    ```bash
    git add chatwoot-base
    git commit -m "Update chatwoot base"
    git push
    ```
    *O Coolify detectará o push e fará o rebuild automaticamente.*

## Solução de Problemas

71: Se ocorrer erro de autenticação no banco (`ActiveRecord::DatabaseConnectionError`):
72: 1.  Verifique se o `.env` tem a senha correta (`PostgresPdvDMais`).
73: 2.  O Dockerfile já remove automaticamente arquivos `.env` conflitantes da imagem base.
74: 
75: ## 📦 Repositório Completo (Full Source)
76: 
77: Este repositório foi configurado para conter **100% dos arquivos necessários**, incluindo a base do Chatwoot (`chatwoot-base`).
78: -   Não há dependência de submódulos git externos que possam falhar no build.
79: -   Recursos como `package.json`, `Gemfile.lock` e arquivos de banco estão versionados diretamente aqui para garantir estabilidade no Coolify.
# ErpChatwoot (Wrapper Deploy)

Este repositório contém a estratégia de deploy "Wrapper" para o Chatwoot customizado (`MenuPdvD+`). Em vez de manter um fork completo, usamos um `Dockerfile` na raiz que constrói uma imagem combinando o `chatwoot-base` (upstream) e as customizações.

Prejeto contem menu adicionado via enterprise para adicionar novas telas de financeiro (iframe), kanban personalizavel e gestão de contatos do chatwoot com agrupamento por empresa

## Estrutura

-   **`Dockerfile`**: Multistage build que clona dependências, copia o `chatwoot-base` e aplica os arquivos do `MenuPdvD+` por cima.
-   **`docker-compose.yaml`**: Orquestração de produção com Postgres (pgvector), Redis e Sidekiq.
-   **`deploy.sh`**: Script utilitário para atualizar o upstream, aplicar mudanças e rebuildar.
-   **`.env`**: Configurações sensíveis (NÃO commitar). Use `.env.example` como base.

## Como Fazer Deploy

1.  **Configurar Variáveis:**
    Copie o exemplo e ajuste as senhas:
    ```bash
    cp .env.example .env
    # Edite POSTGRES_PASSWORD, REDIS_PASSWORD, etc.
    ```

2.  **Iniciar (Primeira Vez):**
    ```bash
    ./deploy.sh
    # OU
    docker-compose up -d --build
    ```

3.  **Preparar Banco de Dados:**
    Necessário apenas na primeira instalação:
    ```bash
    docker-compose run --rm rails bundle exec rails db:chatwoot_prepare
    ```

## Manutenção

-   **Atualizar Chatwoot Base:**
    O script `deploy.sh` automaticamente faz `git pull` na pasta `chatwoot-base` antes do build.

-   **Logs:**
    ```bash
    docker-compose logs -f rails
    ```

-   **Restart:**
    ```bash
    docker-compose restart
    ```

## Solução de Problemas

Se ocorrer erro de autenticação no banco (`ActiveRecord::DatabaseConnectionError`):
1.  Verifique se o `.env` tem a senha correta (`PostgresPdvDMais` ou a que você definiu).
2.  Garanta que não há `.env` conflitante dentro da imagem (o Dockerfile atual já remove o `.env` interno do base).
3.  Se mudou a senha recentemente, pode ser necessário resetar o volume do banco (cuidado com perda de dados).
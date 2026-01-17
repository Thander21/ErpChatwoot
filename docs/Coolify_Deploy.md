# Guia de Deploy no Coolify

Este guia explica como configurar o projeto `ErpChatwoot` no Coolify e ativar as funcionalidades Enterprise.

## 1. Configuração do Projeto

1.  **Criar Novo Recurso:**
    -   No dashboard do Coolify, clique em `+ New Resource`.
    -   Escolha **Git Repository** (ou **Public Repository** se for público).
    -   Cole a URL: `https://github.com/Thander21/ErpChatwoot`

2.  **Configurações de Build:**
    -   **Build Pack:** Selecione `Docker Compose`.
    -   **Base Directory:** `/` (raiz).
    -   **Docker Compose File:** `docker-compose.yaml`

3.  **Variáveis de Ambiente (.env):**
    -   Vá na aba **Environment Variables**.
    -   Copie o conteúdo do seu `.env` local (ou use o `.env.example` como base e preencha as senhas).
    -   **Importante:** Garanta que `POSTGRES_PASSWORD`, `REDIS_PASSWORD` e `SECRET_KEY_BASE` estejam definidos.

4.  **Deploy:**
    -   Clique em **Deploy**.
    -   Aguarde o build terminar. O Coolify vai construir a imagem customizada e subir os serviços `rails`, `sidekiq`, `postgres` e `redis`.

## 2. Ativação Enterprise (Pós-Deploy)

Após o deploy estar marcado como "Running" e saudável:

1.  **Acessar Terminal:**
    -   No painel do recurso no Coolify, clique no botão **Terminal** (ícone `>_`) do serviço `rails` (geralmente nomeado como `rails` ou o nome do container principal).
    -   *Nota:* Se o Coolify mostrar múltiplos containers, escolha o que executa o `rails`.

2.  **Executar Comando de Ativação:**
    Cole e execute o seguinte comando no terminal interativo:

    ```bash
    bundle exec rails runner "
    InstallationConfig.find_or_create_by(name: 'INSTALLATION_PRICING_PLAN').update(value: 'enterprise')
    InstallationConfig.find_or_create_by(name: 'INSTALLATION_PRICING_PLAN_QUANTITY').update(value: 999999)
    puts 'Licença enterprise configurada!'
    "
    ```

3.  **Verificar:**
    -   Reinicie o browser ou faça logout/login no Chatwoot.
    -   As funcionalidades Enterprise devem estar disponíveis.

## 3. Manutenção

-   **Atualizações:**
    -   Para atualizar, basta fazer push no repositório GitHub. O Coolify (se configurado com autodeploy) fará o rebuild automático.
    -   O script de build sempre baixa a versão mais recente do `chatwoot-base` do upstream.

-   **SSH Debug (Opcional):**
    -   Se preferir usar SSH direto no servidor do Coolify:
        ```bash
        docker ps | grep rails
        docker exec -it <container_id> bundle exec rails c
        ```

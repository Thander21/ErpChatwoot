# Regras de Desenvolvimento do Projeto ErpChatwoot

## 🎯 Visão Geral

Este projeto utiliza uma arquitetura baseada em **composição via Docker**, mantendo o código original do Chatwoot isolado das personalizações. Esta abordagem permite:

- ✅ Atualizações do upstream sem conflitos
- ✅ Personalização total sem fork do core
- ✅ Manutenção simplificada
- ✅ Rollback rápido se necessário

## 🏗️ Arquitetura do Projeto

### Componentes Principais:

#### 1. **chatwoot-base/** (SOMENTE LEITURA ❌)

- Contém o código fonte original do Chatwoot
- **REGRA CRÍTICA**: Este diretório **NÃO DEVE** ser alterado diretamente
- Serve como a fonte upstream imutável do projeto
- Atualizável via `update_upstream.sh`

#### 2. **MenuPdvDmais/** (Área de Trabalho ✅)

- Contém **TODAS** as personalizações e extensões do ERP
- Estrutura interna organizada:
  ```
  MenuPdvDmais/
  ├── enterprise/          # Funcionalidades Enterprise (Kanban, Financeiro, Contatos)
  │   ├── app/
  │   ├── config/
  │   └── ...
  ├── core-patches/        # Arquivos que sobrescrevem o core do Chatwoot
  │   ├── app/
  │   ├── config/
  │   └── ...
  ├── db/migrate/          # Migrações de banco de dados adicionais
  ├── app/                 # Controllers e models customizados
  └── config/              # Configurações customizadas
  ```

#### 3. **Dockerfile** (Orquestrador 🐳)

- Responsável por compilar o projeto final
- Processo de build:
  1. Instala dependências (Ruby, Node.js, etc.)
  2. Copia `chatwoot-base/` para o diretório de trabalho
  3. Aplica as alterações do `MenuPdvDmais/` sobre a base
  4. Realiza ajustes de configuração (Gemfile, vite.config.ts, routes, etc.)
  5. Compila assets e prepara produção

## 🛠️ Fluxo de Trabalho Para Modificações

### ⚠️ NUNCA edite arquivos dentro de `chatwoot-base/`

### Cenário 1: Modificar um arquivo existente do core

**Exemplo**: Você precisa alterar `app/controllers/api/v1/accounts/conversations_controller.rb`

1. **Verifique se já existe em MenuPdvDmais:**

   ```bash
   # Se já existir, edite diretamente
   vim MenuPdvDmais/core-patches/app/controllers/api/v1/accounts/conversations_controller.rb
   ```

2. **Se não existir, crie a estrutura:**

   ```bash
   # Copie o arquivo original
   mkdir -p MenuPdvDmais/core-patches/app/controllers/api/v1/accounts/
   cp chatwoot-base/app/controllers/api/v1/accounts/conversations_controller.rb \
      MenuPdvDmais/core-patches/app/controllers/api/v1/accounts/
   ```

3. **Edite o arquivo em MenuPdvDmais:**

   ```bash
   vim MenuPdvDmais/core-patches/app/controllers/api/v1/accounts/conversations_controller.rb
   ```

4. **Verifique o Dockerfile:**
   ```dockerfile
   # O Dockerfile deve ter uma instrução que copia MenuPdvDmais sobre chatwoot-base
   COPY MenuPdvDmais/ ./
   # Ou especificamente:
   COPY MenuPdvDmais/core-patches/ ./
   ```

### Cenário 2: Adicionar novas funcionalidades Enterprise

**Exemplo**: Criar um novo menu "Relatórios"

1. **Adicione os arquivos em `MenuPdvDmais/enterprise/`:**

   ```bash
   # Criar controller
   vim MenuPdvDmais/enterprise/app/controllers/enterprise/reports_controller.rb

   # Criar views
   mkdir -p MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/reports
   vim MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/reports/Index.vue
   ```

2. **Adicione rotas:**

   ```ruby
   # MenuPdvDmais/enterprise/config/routes/enterprise.rb
   namespace :enterprise do
     resources :reports, only: [:index]
   end
   ```

3. **Update sidebar:**
   ```javascript
   // MenuPdvDmais/enterprise/app/javascript/dashboard/components/layout/Sidebar.vue
   // Adicione o novo menu
   ```

### Cenário 3: Adicionar migrações de banco de dados

**Exemplo**: Adicionar campo `archived_at` na tabela `conversations`

1. **Crie a migração em `MenuPdvDmais/db/migrate/`:**

   ```bash
   # Use timestamp para o nome do arquivo
   vim MenuPdvDmais/db/migrate/20260212_add_archived_at_to_conversations.rb
   ```

2. **Conteúdo da migração:**

   ```ruby
   class AddArchivedAtToConversations < ActiveRecord::Migration[7.0]
     def change
       add_column :conversations, :archived_at, :datetime
       add_column :conversations, :archived_by_id, :bigint
       add_index :conversations, :archived_at
     end
   end
   ```

3. **Docker irá executar automaticamente:**
   ```dockerfile
   # No Dockerfile
   RUN bundle exec rails db:migrate
   ```

### Cenário 4: Alterar dependências

**Importante**: As alterações devem ser orquestradas via `Dockerfile`, NÃO editando Gemfile/package.json diretamente em chatwoot-base.

**Exemplo**: Adicionar uma gem

1. **Edite o Dockerfile:**

   ```dockerfile
   # Adicione a gem programaticamente
   RUN echo "gem 'minha_gem', '~> 1.0'" >> Gemfile
   RUN bundle install
   ```

2. **Ou crie um Gemfile.append em MenuPdvDmais:**
   ```dockerfile
   COPY MenuPdvDmais/Gemfile.append /tmp/
   RUN cat /tmp/Gemfile.append >> Gemfile && bundle install
   ```

## 🔍 Padrões e Anti-Padrões

### ✅ FAÇA:

- Sempre trabalhe em `MenuPdvDmais/`
- Use `core-patches/` para sobrescrever core
- Use `enterprise/` para novos recursos
- Mantenha a estrutura de diretórios do Rails/Vue.js
- Adicione comentários explicando o porquê da modificação
- Teste localmente com `docker-compose up --build`

### ❌ NÃO FAÇA:

- Editar arquivos em `chatwoot-base/`
- Commitar arquivos `.env` (use `.env.example`)
- Fazer alterações que quebram atualizações do upstream
- Ignorar a estrutura de diretórios do projeto
- Fazer hard-code de credenciais

## 🐛 Troubleshooting

### Problema: Minhas alterações não aparecem

**Solução:**

```bash
# Rebuild completo
docker-compose down
docker-compose build --no-cache
docker-compose up
```

### Problema: Erro de permissão no build

**Solução:**

```bash
# Verifique o dono dos arquivos
ls -la MenuPdvDmais/
# Se necessário, ajuste permissões
chmod -R 755 MenuPdvDmais/
```

### Problema: Migração não executou

**Solução:**

```bash
# Entre no container
docker-compose exec app bash
# Execute manualmente
bundle exec rails db:migrate
```

### Problema: Assets não compilaram

**Solução:**

```bash
# Dentro do container
bundle exec rails assets:precompile
# Ou force rebuild
docker-compose build --no-cache app
```

## 🔄 Atualizando o Upstream

Para manter seu Chatwoot atualizado com a versão oficial:

```bash
# 1. Atualizar chatwoot-base
./update_upstream.sh

# 2. Testar localmente
docker-compose up --build

# 3. Se tudo OK, commit
git add chatwoot-base
git commit -m "chore: update chatwoot base to latest version"
git push
```

## 📖 Diretrizes para IA (Antigravity/Cursor)

### Ao Analisar Código:

- Lembre-se que o código efetivo é uma **fusão** de `chatwoot-base` + `MenuPdvDmais`
- Priorize análise de arquivos em `MenuPdvDmais/` pois são as customizações ativas
- Se um arquivo existe em ambos, `MenuPdvDmais/` prevalece

### Ao Sugerir Alterações:

- **SEMPRE** sugira alterações em arquivos dentro de `MenuPdvDmais/` ou no `Dockerfile`
- **JAMAIS** sugira diffs aplicados ao `chatwoot-base/`
- Se a alteração for em arquivo que só existe em `chatwoot-base/`:
  1. Crie a cópia modificada em `MenuPdvDmais/core-patches/`
  2. Mantenha a estrutura de diretórios
  3. Verifique se o Dockerfile copia corretamente

### Ao Criar Novas Funcionalidades:

- Use `MenuPdvDmais/enterprise/` para código novo
- Siga as convenções do Rails (MVC)
- Siga as convenções do Vue.js (componentes SFC)
- Adicione comentários em português explicando a funcionalidade

## 🎯 Funcionalidades Enterprise Implementadas

### 1. 💰 Financeiro (Iframe)

- **Localização**: `MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/financeiro/`
- **Propósito**: Integração visual de telas financeiras externas
- **Tech**: Vue.js, iframe component

### 2. 📋 Kanban Personalizável

- **Localização**: `MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/kanban/`
- **Propósito**: Organizar conversas e tarefas em colunas drag-and-drop
- **Features**: Prioridades, arquivamento, filtros
- **Tech**: Vue.js, VueDraggable, Ruby on Rails API

### 3. 🏢 Gestão de Contatos (Agrupamento)

- **Localização**: `MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/contacts/`
- **Propósito**: Visualização avançada com agrupamento por empresa
- **Tech**: Vue.js, custom grouping logic

## 🚀 Comandos Úteis

```bash
# Desenvolvimento local
docker-compose up --build

# Rebuild completo
docker-compose down && docker-compose build --no-cache && docker-compose up

# Ver logs
docker-compose logs -f app

# Entrar no container
docker-compose exec app bash

# Executar Rails console
docker-compose exec app bundle exec rails console

# Executar migrações
docker-compose exec app bundle exec rails db:migrate

# Resetar banco (CUIDADO!)
docker-compose exec app bundle exec rails db:reset
```

## 📚 Tech Stack Summary

- **Backend**: Ruby on Rails 7.x, PostgreSQL (com pgvector), Redis, Sidekiq
- **Frontend**: Vue.js 3.x, Vite, JavaScript ES6+
- **DevOps**: Docker, Docker Compose
- **Deployment**: Coolify (GitOps)

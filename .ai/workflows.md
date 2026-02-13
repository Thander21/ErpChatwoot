# Workflows - ErpChatwoot

## 🎯 Visão Geral

Este documento descreve os workflows detalhados para desenvolvimento no ErpChatwoot, seguindo a arquitetura overlay/wrapper.

---

## 📝 Workflow 1: Adicionar Nova Funcionalidade Enterprise

### Objetivo

Criar uma nova funcionalidade independente que não sobrescreve código do core.

### Exemplo Prático

Criar um novo menu "Relatórios de Vendas"

### Passos

#### 1. Criar estrutura de backend

```bash
# 1.1 Criar controller
mkdir -p MenuPdvDmais/enterprise/app/controllers/enterprise/sales_reports
cat > MenuPdvDmais/enterprise/app/controllers/enterprise/sales_reports/reports_controller.rb << 'EOF'
# frozen_string_literal: true

# Controller para relatórios de vendas
class Enterprise::SalesReports::ReportsController < ApplicationController
  before_action :authenticate_user!

  def index
    @reports = SalesReport.where(account_id: Current.account.id)
                          .order(created_at: :desc)
    render json: @reports
  end

  def show
    @report = SalesReport.find(params[:id])
    render json: @report
  end
end
EOF

# 1.2 Criar model (se necessário)
mkdir -p MenuPdvDmais/enterprise/app/models
cat > MenuPdvDmais/enterprise/app/models/sales_report.rb << 'EOF'
# frozen_string_literal: true

# Model para relatórios de vendas
class SalesReport < ApplicationRecord
  belongs_to :account
  belongs_to :user

  validates :title, presence: true
  validates :report_type, presence: true
end
EOF
```

#### 2. Criar migração

```bash
# 2.1 Criar arquivo de migração
cat > MenuPdvDmais/db/migrate/$(date +%Y%m%d%H%M%S)_create_sales_reports.rb << 'EOF'
# frozen_string_literal: true

# Migração para criar tabela de relatórios de vendas
class CreateSalesReports < ActiveRecord::Migration[7.0]
  def change
    create_table :sales_reports do |t|
      t.references :account, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.string :report_type, null: false
      t.jsonb :data, default: {}
      t.timestamps
    end

    add_index :sales_reports, :report_type
    add_index :sales_reports, :created_at
  end
end
EOF
```

#### 3. Adicionar rotas

```bash
# 3.1 Criar arquivo de rotas enterprise
mkdir -p MenuPdvDmais/enterprise/config/routes
cat > MenuPdvDmais/enterprise/config/routes/sales_reports.rb << 'EOF'
# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :enterprise do
    namespace :sales_reports do
      resources :reports, only: [:index, :show, :create]
    end
  end
end
EOF
```

#### 4. Criar componentes Vue.js

```bash
# 4.1 Criar estrutura de componentes
mkdir -p MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/sales-reports/components

# 4.2 Criar página index
cat > MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/sales-reports/Index.vue << 'EOF'
<template>
  <div class="sales-reports-container">
    <h1>Relatórios de Vendas</h1>
    <div v-if="loading">Carregando...</div>
    <div v-else class="reports-list">
      <report-card
        v-for="report in reports"
        :key="report.id"
        :report="report"
        @click="viewReport(report)"
      />
    </div>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue';
import axios from 'axios';
import ReportCard from './components/ReportCard.vue';

export default {
  name: 'SalesReportsIndex',
  components: { ReportCard },
  setup() {
    const reports = ref([]);
    const loading = ref(true);

    const fetchReports = async () => {
      try {
        const response = await axios.get('/enterprise/sales_reports/reports');
        reports.value = response.data;
      } catch (error) {
        console.error('Erro ao carregar relatórios:', error);
      } finally {
        loading.value = false;
      }
    };

    onMounted(() => {
      fetchReports();
    });

    return { reports, loading };
  }
};
</script>
EOF
```

#### 5. Adicionar no menu lateral

```bash
# 5.1 Editar/criar patch do Sidebar
cp chatwoot-base/app/javascript/dashboard/components/layout/Sidebar.vue \
   MenuPdvDmais/core-patches/app/javascript/dashboard/components/layout/Sidebar.vue

# 5.2 Adicionar item no menu (editar manualmente)
# Procurar pela seção de menu items e adicionar:
# {
#   icon: 'chart-bar',
#   label: 'Relatórios',
#   key: 'sales_reports',
#   toState: 'sales_reports_dashboard',
# }
```

#### 6. Testar localmente

```bash
# 6.1 Rebuild
docker-compose down
docker-compose build --no-cache
docker-compose up -d

# 6.2 Executar migrações
docker-compose exec app bundle exec rails db:migrate

# 6.3 Verificar logs
docker-compose logs -f app
```

---

## 🔧 Workflow 2: Patch de Arquivo do Core

### Objetivo

Modificar comportamento de arquivo existente no chatwoot-base.

### Exemplo Prático

Adicionar campo custom no ConversationsController

### Passos

#### 1. Identificar arquivo a ser modificado

```bash
# 1.1 Encontrar arquivo
find chatwoot-base -name "*conversations_controller.rb" -type f
# Resultado: chatwoot-base/app/controllers/api/v1/accounts/conversations_controller.rb
```

#### 2. Copiar para core-patches

```bash
# 2.1 Criar estrutura
mkdir -p MenuPdvDmais/core-patches/app/controllers/api/v1/accounts/

# 2.2 Copiar arquivo
cp chatwoot-base/app/controllers/api/v1/accounts/conversations_controller.rb \
   MenuPdvDmais/core-patches/app/controllers/api/v1/accounts/conversations_controller.rb
```

#### 3. Fazer modificações

```ruby
# 3.1 Editar arquivo copiado
# MenuPdvDmais/core-patches/app/controllers/api/v1/accounts/conversations_controller.rb

class Api::V1::Accounts::ConversationsController < Api::V1::Accounts::BaseController
  # ... código existente ...

  # PATCH: Adicionar campo custom no response
  def conversation_params
    super.merge(
      archived_at: params[:archived_at],
      archived_by_id: params[:archived_by_id]
    )
  end

  # PATCH: Adicionar método custom
  def archive
    @conversation.update!(
      archived_at: Time.current,
      archived_by_id: Current.user.id
    )
    render json: @conversation
  end
end
```

#### 4. Verificar Dockerfile

```dockerfile
# Verificar se há instrução para copiar core-patches
# Deve conter algo como:
COPY MenuPdvDmais/core-patches/ ./
# OU
COPY MenuPdvDmais/ ./
```

#### 5. Adicionar comentário no arquivo

```ruby
# IMPORTANTE: Adicionar header no arquivo modificado
# frozen_string_literal: true

# PATCH ErpChatwoot: Adicionado suporte para arquivamento de conversas
# Data: 2026-02-12
# Autor: [seu nome]
# Ticket/Issue: #123
# Modificações:
# - Adicionado método archive
# - Adicionado campos archived_at e archived_by_id em conversation_params
```

#### 6. Testar

```bash
# 6.1 Rebuild
docker-compose build app
docker-compose up -d app

# 6.2 Verificar se arquivo foi sobrescrito
docker-compose exec app cat app/controllers/api/v1/accounts/conversations_controller.rb | head -20
```

---

## 💾 Workflow 3: Adicionar Migração de Banco

### Objetivo

Adicionar nova tabela ou modificar schema existente.

### Exemplo Prático

Adicionar campos de arquivamento em conversations

### Passos

#### 1. Criar arquivo de migração

```bash
# 1.1 Usar timestamp
TIMESTAMP=$(date +%Y%m%d%H%M%S)
cat > MenuPdvDmais/db/migrate/${TIMESTAMP}_add_archive_fields_to_conversations.rb << 'EOF'
# frozen_string_literal: true

# Adiciona campos de arquivamento para conversas
class AddArchiveFieldsToConversations < ActiveRecord::Migration[7.0]
  def change
    add_column :conversations, :archived_at, :datetime
    add_column :conversations, :archived_by_id, :bigint

    add_index :conversations, :archived_at
    add_index :conversations, :archived_by_id
    add_foreign_key :conversations, :users, column: :archived_by_id
  end
end
EOF
```

#### 2. Verificar Dockerfile

```dockerfile
# Verificar se migrações do MenuPdvDmais são copiadas
COPY MenuPdvDmais/db/migrate/ ./db/migrate/
# OU
COPY MenuPdvDmais/ ./
```

#### 3. Executar migração

```bash
# 3.1 Rebuild e executar
docker-compose build app
docker-compose up -d app
docker-compose exec app bundle exec rails db:migrate

# 3.2 Verificar status
docker-compose exec app bundle exec rails db:migrate:status
```

#### 4. Criar migração de rollback (opcional)

```ruby
# Adicionar método down na migração
class AddArchiveFieldsToConversations < ActiveRecord::Migration[7.0]
  def up
    add_column :conversations, :archived_at, :datetime
    add_column :conversations, :archived_by_id, :bigint
    add_index :conversations, :archived_at
    add_index :conversations, :archived_by_id
    add_foreign_key :conversations, :users, column: :archived_by_id
  end

  def down
    remove_foreign_key :conversations, column: :archived_by_id
    remove_index :conversations, :archived_by_id
    remove_index :conversations, :archived_at
    remove_column :conversations, :archived_by_id
    remove_column :conversations, :archived_at
  end
end
```

---

## 🔄 Workflow 4: Atualizar Upstream (Chatwoot Base)

### Objetivo

Atualizar chatwoot-base para versão mais recente do upstream.

### Passos

#### 1. Executar script de atualização

```bash
# 1.1 Usar script fornecido
./update_upstream.sh
```

#### 2. Revisar mudanças

```bash
# 2.1 Ver diff
git diff chatwoot-base/

# 2.2 Verificar se há conflitos potenciais com patches
# Comparar arquivos em MenuPdvDmais/core-patches/ com novos arquivos em chatwoot-base/
```

#### 3. Testar localmente

```bash
# 3.1 Rebuild completo
docker-compose down
docker-compose build --no-cache
docker-compose up -d

# 3.2 Verificar logs
docker-compose logs -f app

# 3.3 Testar funcionalidades críticas
# - Login
# - Navegação
# - Funcionalidades Enterprise (Kanban, Financeiro, Contatos)
```

#### 4. Resolver conflitos (se houver)

```bash
# 4.1 Se um arquivo em core-patches não funciona mais
# Copiar nova versão do chatwoot-base
cp chatwoot-base/path/to/file.rb MenuPdvDmais/core-patches/path/to/file.rb

# 4.2 Re-aplicar modificações manualmente
# Editar MenuPdvDmais/core-patches/path/to/file.rb
```

#### 5. Commit e deploy

```bash
# 5.1 Commit
git add chatwoot-base MenuPdvDmais
git commit -m "chore: update chatwoot base to v3.x.x"

# 5.2 Push
git push origin main

# 5.3 Coolify irá detectar e fazer deploy automaticamente
```

---

## 🧪 Workflow 5: Testar Mudanças Localmente

### Objetivo

Validar alterações antes de fazer commit.

### Passos

#### 1. Rebuild ambiente

```bash
# 1.1 Limpar tudo
docker-compose down -v  # -v remove volumes também

# 1.2 Rebuild sem cache
docker-compose build --no-cache

# 1.3 Subir serviços
docker-compose up -d
```

#### 2. Verificar logs

```bash
# 2.1 App logs
docker-compose logs -f app

# 2.2 Sidekiq logs
docker-compose logs -f sidekiq

# 2.3 Verificar erros
docker-compose logs app | grep -i error
```

#### 3. Executar migrações

```bash
# 3.1 Se necessário
docker-compose exec app bundle exec rails db:migrate

# 3.2 Verificar status
docker-compose exec app bundle exec rails db:migrate:status
```

#### 4. Testar via browser

```bash
# 4.1 Acessar aplicação
# http://localhost:3000

# 4.2 Testar funcionalidades:
# - Login
# - Navegação para nova feature
# - CRUD operations
# - Validações
```

#### 5. Executar console Rails (debugging)

```bash
# 5.1 Abrir console
docker-compose exec app bundle exec rails console

# 5.2 Testar models
> SalesReport.count
> User.first
> Conversation.where(archived_at: nil).count
```

#### 6. Verificar assets

```bash
# 6.1 Verificar compilação
docker-compose exec app ls -la public/vite/

# 6.2 Recompilar se necessário
docker-compose exec app bundle exec rails assets:precompile
```

---

## 📦 Workflow 6: Adicionar Dependência

### Objetivo

Adicionar nova gem Ruby ou package NPM.

### Para Gems (Backend)

```bash
# Opção 1: Via Dockerfile
cat >> Dockerfile << 'EOF'
# Adicionar gem custom
RUN echo "gem 'minha_gem', '~> 1.0'" >> Gemfile && bundle install
EOF

# Opção 2: Via arquivo append
cat > MenuPdvDmais/Gemfile.append << 'EOF'
gem 'minha_gem', '~> 1.0'
EOF

# Atualizar Dockerfile
# ADD MenuPdvDmais/Gemfile.append /tmp/
# RUN cat /tmp/Gemfile.append >> Gemfile && bundle install
```

### Para NPM Packages (Frontend)

```bash
# Via Dockerfile
cat >> Dockerfile << 'EOF'
# Adicionar package custom
RUN npm install minha-lib@1.0.0
EOF

# Rebuild
docker-compose build --no-cache app
```

---

## 🚀 Workflow 7: Deploy para Produção

### Objetivo

Fazer deploy via Coolify (GitOps).

### Passos

```bash
# 1. Commit mudanças
git add .
git commit -m "feat: adicionar relatórios de vendas"

# 2. Push para main
git push origin main

# 3. Coolify detecta automaticamente e faz:
#    - git pull
#    - docker build
#    - docker-compose up (com zero-downtime)

# 4. Monitorar deploy no painel Coolify
# 5. Verificar logs em produção
```

---

## ✅ Checklist de Qualidade

Antes de fazer commit, verificar:

- [ ] Código testado localmente
- [ ] Migrações executam sem erro
- [ ] Assets compilam corretamente
- [ ] Logs não mostram erros críticos
- [ ] Funcionalidades existentes não quebraram
- [ ] Código segue convenções Rails/Vue.js
- [ ] Comentários em português explicando modificações
- [ ] Arquivos em `MenuPdvDmais/`, nunca em `chatwoot-base/`
- [ ] `.env` não foi commitado
- [ ] Mensagem de commit segue Conventional Commits

# Tech Stack - ErpChatwoot

## 🎯 Visão Geral

O ErpChatwoot é uma extensão enterprise do Chatwoot, construída usando uma arquitetura overlay/wrapper que permite personalização sem fork do código original.

## 🔧 Backend

### Ruby on Rails

- **Versão**: 7.x
- **Propósito**: Framework MVC principal
- **Localização**:
  - Core: `chatwoot-base/app/`
  - Customizações: `MenuPdvDmais/enterprise/app/`, `MenuPdvDmais/core-patches/app/`

### PostgreSQL

- **Versão**: 14+ com extensão pgvector
- **Propósito**: Banco de dados principal
- **Features utilizadas**:
  - Relational data storage
  - Vector search (pgvector para features futuras de IA)
  - Full-text search
- **Localização config**: `docker-compose.yaml`

### Redis

- **Versão**: 7.x
- **Propósito**: Cache, sessões, filas de jobs
- **Uso**:
  - Cache de queries
  - Sidekiq job queue
  - Real-time notifications
- **Localização config**: `docker-compose.yaml`

### Sidekiq

- **Propósito**: Background job processing
- **Uso**:
  - Envio de emails
  - Processamento de webhooks
  - Tarefas agendadas

## 🎨 Frontend

### Vue.js

- **Versão**: 3.x (Composition API)
- **Propósito**: Framework JavaScript principal
- **Localização**:
  - Core: `chatwoot-base/app/javascript/`
  - Enterprise: `MenuPdvDmais/enterprise/app/javascript/`
- **Features utilizadas**:
  - Composition API
  - Vue Router
  - Reactive state management

### Vite

- **Propósito**: Build tool e dev server
- **Configuração**: `vite.config.ts`
- **Features**:
  - Hot Module Replacement (HMR)
  - Fast builds
  - Asset optimization

### JavaScript/ES6+

- **Padrões**:
  - ES6 modules
  - Async/await
  - Destructuring
  - Arrow functions
- **Linting**: ESLint (configuração do Chatwoot base)

### CSS/SCSS

- **Abordagem**:
  - SCSS para componentes Enterprise
  - BEM-like naming conventions
  - Scoped styles em componentes Vue

## 🐳 DevOps

### Docker

- **Versão**: 20.10+
- **Arquivos**:
  - `Dockerfile`: Multi-stage build principal
  - `docker-compose.yaml`: Orquestração de produção
  - `docker-compose-dev.yaml`: Desenvolvimento local
- **Images utilizadas**:
  - Node.js (para build de assets)
  - Ruby (runtime)
  - PostgreSQL
  - Redis

### Docker Compose

- **Serviços**:
  - `app`: Aplicação Rails principal
  - `sidekiq`: Background workers
  - `postgres`: Banco de dados
  - `redis`: Cache e filas
- **Volumes**:
  - Dados do PostgreSQL persistidos
  - Assets compilados

### Coolify

- **Propósito**: GitOps deployment platform
- **Workflow**:
  - Push para repositório → Coolify detecta
  - Build automático via Dockerfile
  - Deploy com zero-downtime

## 📦 Dependências Principais

### Backend (Gems)

```ruby
# Core Rails
gem 'rails', '~> 7.0'
gem 'pg', '~> 1.1'
gem 'redis', '~> 4.0'
gem 'sidekiq', '~> 6.0'

# Assets
gem 'vite_rails'

# API
gem 'jwt'
gem 'pundit' # Authorization
gem 'kaminari' # Pagination
```

### Frontend (NPM)

```json
{
  "vue": "^3.x",
  "vue-router": "^4.x",
  "vite": "^4.x",
  "axios": "^1.x",
  "vuedraggable": "^4.x" // Para Kanban
}
```

## 🏗️ Arquitetura Overlay/Wrapper

### Conceito

- **Base imutável**: `chatwoot-base/` contém código original
- **Overlay**: `MenuPdvDmais/` contém customizações
- **Composição**: Dockerfile mescla ambos na build

### Vantagens

✅ Atualizações do upstream sem conflitos  
✅ Personalização total sem fork  
✅ Manutenção simplificada  
✅ Rollback rápido

### Process de Build

```dockerfile
# 1. Base image com dependências
FROM ruby:3.x

# 2. Copiar chatwoot-base
COPY chatwoot-base/ /app/

# 3. Aplicar overlay MenuPdvDmais
COPY MenuPdvDmais/ /app/

# 4. Build assets
RUN bundle install
RUN npm install
RUN bundle exec rails assets:precompile

# 5. Runtime
CMD ["bundle", "exec", "rails", "server"]
```

## 🛠️ Ferramentas de Desenvolvimento

### Obrigatórias

- Docker Desktop / Docker Engine
- Git
- Editor (VS Code, Cursor, etc.)

### Recomendadas

- Ruby Version Manager (RVM/rbenv)
- Node Version Manager (nvm)
- PostgreSQL client (psql)
- Redis CLI

## 📊 Monitoramento e Logs

### Logs

```bash
# Application logs
docker-compose logs -f app

# Sidekiq logs
docker-compose logs -f sidekiq

# PostgreSQL logs
docker-compose logs -f postgres
```

### Debugging

- Rails console: `docker-compose exec app bundle exec rails console`
- Pry/byebug para breakpoints
- Vue DevTools para frontend

## 🔐 Segurança

### Variáveis de Ambiente

- `.env`: Configurações locais (NÃO commitar)
- `.env.example`: Template público
- Coolify: Environment variables via UI

### Secrets

- `SECRET_KEY_BASE`: Gerado via `openssl rand -hex 64`
- Database passwords
- API keys
- JWT secrets

## 🚀 Performance

### Backend

- Query optimization (índices no PostgreSQL)
- Cache com Redis
- Background jobs com Sidekiq
- Pagination para listas grandes

### Frontend

- Code splitting (Vite)
- Lazy loading de componentes
- Asset compression
- CDN para assets estáticos (quando aplicável)

## 📚 Referências

- **Ruby on Rails**: https://rubyonrails.org/
- **Vue.js**: https://vuejs.org/
- **Chatwoot**: https://github.com/chatwoot/chatwoot
- **Docker**: https://docs.docker.com/
- **PostgreSQL**: https://www.postgresql.org/docs/

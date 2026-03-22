# Tech Stack - ErpChatwoot

## 🎯 Visão Geral
O ErpChatwoot é uma extensão enterprise do Chatwoot, construída usando uma arquitetura overlay/wrapper que permite personalização sem fork do código original.

## 🔧 Backend (Ruby on Rails 7.x)
- **Core**: `chatwoot-base/app/`
- **Customizações**: `MenuPdvDmais/enterprise/app/`, `MenuPdvDmais/core-patches/app/`
- **PostgreSQL**: 14+ com extensão `pgvector`.
- **Redis**: 7.x (Cache, Sidekiq, Real-time).
- **Sidekiq**: Processamento de background jobs.

## 🎨 Frontend (Vue.js 3.x)
- **Versão**: Vue 3 (Composition API).
- **Localização Core**: `chatwoot-base/app/javascript/`
- **Localização Enterprise**: `MenuPdvDmais/enterprise/app/javascript/`
- **Build Tool**: Vite.
- **CSS**: SCSS para componentes Enterprise, convenção BEM-like.

## 🐳 DevOps & Orquestração
- **Docker**: Arquivo `Dockerfile` multi-stage (Requer **BuildKit** para performance e cache).
- **Docker Compose**: `docker-compose.yaml` (Prod), `docker-compose-dev.yaml` (Dev).
- **Dev Workflow**: Baseado em builds (`up --build`). **Volumes de bind-mount para código são proibidos** para garantir paridade com a imagem final.
- **Coolify**: Plataforma de deployment GitOps.

## 🏗️ Arquitetura Overlay/Wrapper (REGRA DE OURO)
- **Base imutável**: `chatwoot-base/` contém código original.
- **Overlay**: `MenuPdvDmais/` contém customizações.
- **Composição**: Dockerfile mescla ambos na build.
- **Vantagens**: Atualizações do upstream sem conflitos e personalização sem fork.

## 📦 Dependências Principais
- **Gems**: `rails`, `pg`, `redis`, `sidekiq`, `vite_rails`, `pundit`.
- **NPM**: `vue`, `vue-router`, `vite`, `vuedraggable`.

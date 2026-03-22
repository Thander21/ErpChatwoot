# Troubleshooting - ErpChatwoot

## 🐳 Docker & Build Issues
- **Mudanças não aparecem**: Tente um rebuild completo com `docker-compose down && docker-compose build --no-cache && docker-compose up`.
- **Erro de permissão no build**: Verifique o dono dos arquivos em `MenuPdvDmais/`. Utilize `chmod -R 755 MenuPdvDmais/` se necessário.
- **Container não sobe**: Inspecione os logs com `docker-compose logs -f [service_name]`.

## 💾 Database Issues
- **Migração não executada**: Entre no container da aplicação e execute manualmente: `docker-compose exec app bundle exec rails db:migrate`.
- **Status das migrações**: Verifique o status com `bundle exec rails db:migrate:status`.

## 🛠️ Debugging Tools
- **Rails Console**: `docker-compose exec app bundle exec rails console`.
- **Sidekiq Dashboard**: Acesse o painel do Sidekiq (geralmente em `/sidekiq` com autenticação admin).
- **Vue DevTools**: Utilize a extensão do navegador para depurar o estado reactive do frontend.

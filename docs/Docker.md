# 1. Ensure you're in the correct directory
cd chatwoot-base    

# 2. Start the services (if not already running)
docker-compose up -d

# 2.1 Create database
docker-compose exec rails bundle exec rails db:create

# 2.2 Run migrations
docker-compose exec rails bundle exec rails db:migrate

# 2.3 Run seeds
docker-compose exec rails bundle exec rails db:seed

# 2.4 Restart services to ensure enterprise features load
docker-compose restart rails

# 2.5 Check logs to verify enterprise activation
docker-compose logs rails | grep -i enterprise


## reset chatwoot
 git fetch upstream
git reset --hard upstream/develop

## restar tudo
cd chatwoot-base
docker-compose down -v  # Remove containers e volumes
docker-compose up -d    # Recria tudo do zero
docker-compose exec rails bundle exec rails db:create
docker-compose exec rails bundle exec rails db:migrate
docker-compose exec rails bundle exec rails db:seed


# Passo 2: Limpeza completa
echo "🧹 Limpando cache Docker..."
docker image prune -f
docker volume prune -f
docker container prune -f
docker builder prune -f

## licença interprice Comando via Rails runner (recomendado):
docker-compose exec rails bundle exec rails runner "
InstallationConfig.find_or_create_by(name: 'INSTALLATION_PRICING_PLAN').update(value: 'enterprise')
InstallationConfig.find_or_create_by(name: 'INSTALLATION_PRICING_PLAN_QUANTITY').update(value: 999999)
puts 'Licença enterprise configurada!'
"


## compilar alterações assets
docker-compose exec rails bundle exec rails assets:precompile

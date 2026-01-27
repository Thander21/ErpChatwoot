

# 2. Start the services (if not already running)
docker-compose up -d --build
docker-compose -f docker-compose-dev.yaml up -d --build
docker-compose -f docker-compose-dev.yaml down
docker-compose -f docker-compose-dev.yaml up -d 

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
bundle exec rails runner "InstallationConfig.find_or_create_by(name:'INSTALLATION_PRICING_PLAN').update(value: 'enterprise'); InstallationConfig.find_or_create_by(name: 'INSTALLATION_PRICING_PLAN_QUANTITY').update(value: 999999); puts 'Licença enterprise configurada!'"
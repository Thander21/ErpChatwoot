# Comandos para Atualização (Ambiente DEV)

df -h /

# 1. Parar os containers
  
docker-compose -f docker-compose-dev.yaml stop
docker-compose -f docker-compose-dev.yaml down
docker image prune -a -f     
docker volume prune -a -f    
DOCKER_BUILDKIT=1 docker-compose -f docker-compose-dev.yaml up -d --build

# 2. Rodar a migração

docker compose -f docker-compose-dev.yaml run --rm rails bundle exec rails db:migrate

## Limpeza Seletiva (se preferir controle):

````bash
echo "🧹 Limpando cache Docker..."
docker image prune -a -f      # Remove imagens não usadas
docker volume prune -a -f         # Remove volumes órfãos

```
docker builder prune -a -f        # Remove build cache

## Verificar espaço usado:

```bash
ncdu /
sudo du -h --max-depth=1 /
df -h /
docker system df -v
````

## Diferença entre flags:

- `-f` (force) = não pede confirmação
- `-a` (all) = remove TODAS as imagens não usadas (mais agressivo)
- `--volumes` = inclui volumes órfãos na limpeza

## licença interprice Comando via Rails runner (recomendado):

# rodar no dev

docker-compose exec rails bundle exec rails runner "
InstallationConfig.find_or_create_by(name: 'INSTALLATION_PRICING_PLAN').update(value: 'enterprise')
InstallationConfig.find_or_create_by(name: 'INSTALLATION_PRICING_PLAN_QUANTITY').update(value: 999999)
puts 'Licença enterprise configurada!'
"

# rodar em prod

bundle exec rails runner "InstallationConfig.find_or_create_by(name:'INSTALLATION_PRICING_PLAN').update(value: 'enterprise'); InstallationConfig.find_or_create_by(name: 'INSTALLATION_PRICING_PLAN_QUANTITY').update(value: 999999); puts 'Licença enterprise configurada!'"

## Criar Usuário de Teste (Dev)

Para recriar o usuário `teste@teste.com` / `Teste12!@` após zerar o banco:

```bash
docker exec erpchatwoot_rails_1 bundle exec rails runner '
  email = "teste@teste.com"
  password = "Teste12!@"

  account = Account.first_or_create!(name: "Dev Account")

  user = User.find_or_initialize_by(email: email)
  user.password = password
  user.password_confirmation = password
  user.name = "Teste User"
  user.confirmed_at = Time.current
  user.save!

  AccountUser.find_or_create_by!(user: user, account: account, role: :administrator)

  puts "Usuário de teste criado e confirmado!"
'
```

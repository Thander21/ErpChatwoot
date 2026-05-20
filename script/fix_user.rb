#
# File: script/fix_user.rb
# Last Modified: 06/05/2026
# Dependencies: rails, redis (Redis::Alfred)
# Calls: -
# Description: Cria ou atualiza SuperAdmin, garante vínculo administrador na conta,
#   conta ativa e libera o dashboard limpando o onboarding de instalação no Redis.
#

# docker compose -f docker-compose-dev.yaml exec -T rails bundle exec rails runner - < script/fix_user.rb

email = 'teste@teste.com'
password = 'Teste12!@'

user = User.find_by(email: email)
user.update_column(:type, 'SuperAdmin') if user && user.type != 'SuperAdmin'

sa = SuperAdmin.find_by(email: email) || SuperAdmin.new(email: email)
sa.name = 'Teste User'
sa.password = password
sa.password_confirmation = password
sa.confirmed_at = Time.current
sa.save!

account = Account.first_or_create!(name: 'Dev Account')
account.update!(status: :active)

account_user = AccountUser.find_or_initialize_by(user_id: sa.id, account_id: account.id)
account_user.role = :administrator
account_user.save!

# Sem isso o DashboardController redireciona para /installation/onboarding e parece que a “empresa” não está ativa.
Redis::Alfred.delete(Redis::Alfred::CHATWOOT_INSTALLATION_ONBOARDING)

puts 'SuperAdmin OK, AccountUser administrator, account active, installation onboarding Redis key cleared.'

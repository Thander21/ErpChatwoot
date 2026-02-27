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
AccountUser.find_or_create_by!(user_id: sa.id, account_id: account.id) do |au|
  au.role = :administrator
end

puts 'Single user created and given both SuperAdmin and Account Admin access!'

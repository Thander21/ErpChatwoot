class CreateTelegramAgents < ActiveRecord::Migration[7.1]
  def change
    create_table :telegram_agents do |t|
      t.string :telegram_user_id, null: false
      t.references :user, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true

      t.timestamps
    end

    add_index :telegram_agents, :telegram_user_id, unique: true
    add_index :telegram_agents, [:telegram_user_id, :account_id], unique: true
  end
end

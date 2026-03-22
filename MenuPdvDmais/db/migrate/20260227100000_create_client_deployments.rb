class CreateClientDeployments < ActiveRecord::Migration[7.1]
  def change
    create_table :client_deployments, if_not_exists: true do |t|
      t.references :account, null: false, foreign_key: true
      t.references :company, null: false, foreign_key: true
      t.references :contact, null: true, foreign_key: true
      t.references :assignee, null: true, foreign_key: { to_table: :users }

      t.string :title, null: false
      t.integer :status, default: 0, null: false
      t.date :started_at
      t.date :completed_at
      t.text :notes
      t.jsonb :custom_attributes, default: {}

      t.timestamps
    end

    add_index :client_deployments, [:account_id, :company_id], if_not_exists: true
    add_index :client_deployments, [:account_id, :status], if_not_exists: true
    add_index :client_deployments, [:account_id, :assignee_id], if_not_exists: true
  end
end

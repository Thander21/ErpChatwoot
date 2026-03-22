class CreateDeploymentTrainings < ActiveRecord::Migration[7.1]
  def change
    create_table :deployment_trainings, if_not_exists: true do |t|
      t.references :client_deployment, null: false, foreign_key: true
      t.references :contact, null: false, foreign_key: true
      t.references :trained_by, null: true, foreign_key: { to_table: :users }

      t.string :system_name, null: false
      t.date :trained_at, null: false
      t.integer :duration_minutes
      t.text :notes

      t.timestamps
    end

    add_index :deployment_trainings, :client_deployment_id, if_not_exists: true
    add_index :deployment_trainings, :contact_id, if_not_exists: true
  end
end

class CreateDeploymentSystems < ActiveRecord::Migration[7.1]
  def change
    create_table :deployment_systems, if_not_exists: true do |t|
      t.references :client_deployment, null: false, foreign_key: true
      t.references :installed_by, null: true, foreign_key: { to_table: :users }

      t.string :system_name, null: false
      t.string :version
      t.date :installed_at
      t.text :notes

      t.timestamps
    end

    add_index :deployment_systems, :client_deployment_id, if_not_exists: true
  end
end

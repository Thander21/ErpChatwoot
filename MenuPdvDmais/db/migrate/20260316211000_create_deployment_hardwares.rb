class CreateDeploymentHardwares < ActiveRecord::Migration[7.1]
  def change
    create_table :deployment_hardwares do |t|
      t.references :client_deployment, null: false, foreign_key: true
      t.references :installed_by, null: true, foreign_key: { to_table: :users }

      t.string :hardware_name, null: false
      t.string :serial_number
      t.date :installed_at
      t.text :notes

      t.timestamps
    end

  end
end

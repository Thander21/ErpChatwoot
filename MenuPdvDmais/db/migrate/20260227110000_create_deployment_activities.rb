class CreateDeploymentActivities < ActiveRecord::Migration[7.1]
  def change
    create_table :deployment_activities, if_not_exists: true do |t|
      t.references :client_deployment, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.integer :activity_type, default: 0, null: false
      t.text :description, null: false
      t.datetime :occurred_at, null: false
      t.integer :duration_minutes
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :deployment_activities, [:client_deployment_id, :occurred_at],
              name: 'idx_deployment_activities_by_date', if_not_exists: true
    add_index :deployment_activities, [:client_deployment_id, :activity_type],
              name: 'idx_deployment_activities_by_type', if_not_exists: true
  end
end

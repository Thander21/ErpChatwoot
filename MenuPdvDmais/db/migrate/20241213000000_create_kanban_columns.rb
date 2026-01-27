class CreateKanbanColumns < ActiveRecord::Migration[7.1]
  def change
    create_table :kanban_columns do |t|
      t.references :account, null: false, foreign_key: true
      t.string :name, null: false
      t.string :color, default: '#6b7280'
      t.integer :position, default: 0
      t.timestamps
    end

    add_index :kanban_columns, [:account_id, :position]
  end
end

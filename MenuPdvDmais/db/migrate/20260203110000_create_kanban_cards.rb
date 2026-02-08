class CreateKanbanCards < ActiveRecord::Migration[7.1]
  def change
    create_table :kanban_cards, if_not_exists: true do |t|
      t.references :account, null: false, foreign_key: true
      t.references :conversation, null: true, foreign_key: true
      t.references :contact, null: true, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.references :kanban_column, null: false, foreign_key: true
      t.integer :position, default: 0
      t.jsonb :custom_attributes, default: {}
      t.datetime :due_date
      t.integer :priority, default: 0

      t.timestamps
    end

    add_index :kanban_cards, [:account_id, :kanban_column_id], if_not_exists: true
    add_index :kanban_cards, [:account_id, :conversation_id], if_not_exists: true
    add_index :kanban_cards, [:account_id, :contact_id], if_not_exists: true
    add_index :kanban_cards, [:account_id, :position], if_not_exists: true
  end
end

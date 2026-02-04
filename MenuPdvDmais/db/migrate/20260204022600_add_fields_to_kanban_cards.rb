class AddFieldsToKanbanCards < ActiveRecord::Migration[7.0]
  def change
    add_column :kanban_cards, :company_id, :bigint
    add_column :kanban_cards, :assignee_id, :bigint
    
    add_index :kanban_cards, :company_id
    add_index :kanban_cards, :assignee_id
  end
end

class AddImplementerToKanbanCards < ActiveRecord::Migration[7.1]
  def change
    add_column :kanban_cards, :implementer_id, :bigint
    add_index :kanban_cards, :implementer_id
  end
end

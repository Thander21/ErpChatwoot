class AddDeletedAtToKanbanCards < ActiveRecord::Migration[7.0]
  def change
    add_column :kanban_cards, :deleted_at, :datetime
    add_column :kanban_cards, :deleted_by_id, :integer
    add_index :kanban_cards, :deleted_at
  end
end

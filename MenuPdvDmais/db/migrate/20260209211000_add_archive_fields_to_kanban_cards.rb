class AddArchiveFieldsToKanbanCards < ActiveRecord::Migration[7.0]
  def change
    add_column :kanban_cards, :archived_at, :datetime
    add_column :kanban_cards, :archived_by_id, :integer
    add_index :kanban_cards, :archived_at
  end
end

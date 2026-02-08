class AddPriorityAndDueDateToKanbanCards < ActiveRecord::Migration[7.0]
  def change
    add_column :kanban_cards, :priority, :integer, default: 0 unless column_exists?(:kanban_cards, :priority)
    add_column :kanban_cards, :due_date, :datetime unless column_exists?(:kanban_cards, :due_date)
  end
end

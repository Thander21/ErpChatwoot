# frozen_string_literal: true

class KanbanCard < ApplicationRecord
  belongs_to :account
  belongs_to :conversation, optional: true
  belongs_to :contact, optional: true

  validates :title, presence: true
  validates :kanban_column_id, presence: true

  # Scopes
  scope :by_column, ->(column_id) { where(kanban_column_id: column_id) }
  scope :by_account, ->(account_id) { where(account_id: account_id) }
  scope :ordered, -> { order(position: :asc, created_at: :desc) }

  # Priorities
  enum priority: { low: 0, normal: 1, high: 2, urgent: 3 }

  # Callbacks
  before_create :set_default_position

  private

  def set_default_position
    return if position.present?

    max_position = self.class.where(
      account_id: account_id,
      kanban_column_id: kanban_column_id
    ).maximum(:position) || -1

    self.position = max_position + 1
  end
end

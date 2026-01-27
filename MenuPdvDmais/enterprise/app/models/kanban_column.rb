# frozen_string_literal: true

class KanbanColumn < ApplicationRecord
  belongs_to :account

  validates :name, presence: true

  # Scopes
  scope :by_account, ->(account_id) { where(account_id: account_id) }
  scope :ordered, -> { order(position: :asc) }

  # Callbacks
  before_create :set_default_position

  private

  def set_default_position
    return if position.present?

    max_position = self.class.where(account_id: account_id).maximum(:position) || -1
    self.position = max_position + 1
  end
end

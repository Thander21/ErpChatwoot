# frozen_string_literal: true

class KanbanCard < ApplicationRecord
  belongs_to :account
  belongs_to :conversation, optional: true
  belongs_to :contact, optional: true
  belongs_to :company, class_name: 'Company', optional: true
  belongs_to :assignee, class_name: 'User', optional: true
  belongs_to :implementer, class_name: 'User', optional: true
  belongs_to :archived_by, class_name: 'User', optional: true

  validates :title, presence: true
  validates :kanban_column_id, presence: true

  # Scopes
  default_scope { where(deleted_at: nil) }
  scope :by_column, ->(column_id) { where(kanban_column_id: column_id) }
  scope :by_account, ->(account_id) { where(account_id: account_id) }
  scope :ordered, -> { order(position: :asc, created_at: :desc) }
  scope :active, -> { where(archived_at: nil) }
  scope :archived, -> { where.not(archived_at: nil) }
  scope :deleted, -> { unscope(where: :deleted_at).where.not(deleted_at: nil) }
  scope :all_with_deleted, -> { unscope(where: :deleted_at) }

  # Priorities
  enum priority: { low: 0, normal: 1, high: 2, urgent: 3 }

  # Relationships
  belongs_to :deleted_by, class_name: 'User', optional: true

  # Callbacks
  before_create :set_default_position

  def destroy
    run_callbacks :destroy do
      update(deleted_at: Time.current, deleted_by: Current.user)
    end
  end

  def recover
    update(deleted_at: nil, deleted_by: nil)
  end

  private

  def set_default_position
    return if position.present?

    max_position = self.class.unscoped.where(
      account_id: account_id,
      kanban_column_id: kanban_column_id,
      deleted_at: nil
    ).maximum(:position) || -1

    self.position = max_position + 1
  end
end

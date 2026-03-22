# frozen_string_literal: true

class ClientDeployment < ApplicationRecord
  belongs_to :account
  belongs_to :company
  belongs_to :contact, optional: true
  belongs_to :assignee, class_name: 'User', optional: true

  has_many :deployment_activities, dependent: :destroy
  has_many :deployment_systems, dependent: :destroy
  has_many :deployment_trainings, dependent: :destroy
  has_many :deployment_hardwares, dependent: :destroy
  has_many :deployment_networks, dependent: :destroy
  has_many :deployment_installations, dependent: :destroy

  validates :title, presence: true
  validates :company_id, presence: true

  enum status: {
    pending: 0,
    in_progress: 1,
    completed: 2,
    on_hold: 3
  }

  # Scopes
  scope :by_account, ->(account_id) { where(account_id: account_id) }
  scope :by_company, ->(company_id) { where(company_id: company_id) }
  scope :active, -> { where(status: [:pending, :in_progress]) }
  scope :ordered, -> { order(created_at: :desc) }

  def last_activity
    deployment_activities.order(occurred_at: :desc).first
  end

  def next_schedule
    deployment_activities
      .where(activity_type: :schedule)
      .where('occurred_at >= ?', Time.current)
      .order(occurred_at: :asc)
      .first
  end
end

# frozen_string_literal: true

class DeploymentActivity < ApplicationRecord
  belongs_to :client_deployment
  belongs_to :user

  validates :description, presence: true
  validates :occurred_at, presence: true
  validates :activity_type, presence: true

  enum activity_type: {
    visit: 0,
    training: 1,
    installation: 2,
    support: 3,
    call: 4,
    note: 5,
    schedule: 6
  }

  # Scopes
  scope :ordered, -> { order(occurred_at: :desc) }
  scope :chronological, -> { order(occurred_at: :asc) }
  scope :recent, -> { ordered.limit(20) }
  scope :future_schedules, -> { where(activity_type: :schedule).where('occurred_at >= ?', Time.current).order(occurred_at: :asc) }
end

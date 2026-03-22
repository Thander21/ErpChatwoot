# frozen_string_literal: true

class DeploymentTraining < ApplicationRecord
  belongs_to :client_deployment
  belongs_to :contact
  belongs_to :trained_by, class_name: 'User', optional: true

  validates :system_name, presence: true
  validates :trained_at, presence: true
  validates :contact_id, presence: true

  scope :ordered, -> { order(trained_at: :desc) }
end

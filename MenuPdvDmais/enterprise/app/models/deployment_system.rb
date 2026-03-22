# frozen_string_literal: true

class DeploymentSystem < ApplicationRecord
  belongs_to :client_deployment
  belongs_to :installed_by, class_name: 'User', optional: true

  validates :system_name, presence: true

  scope :ordered, -> { order(installed_at: :desc, created_at: :desc) }
end

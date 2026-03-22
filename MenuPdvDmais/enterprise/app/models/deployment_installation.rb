# frozen_string_literal: true

class DeploymentInstallation < ApplicationRecord
  belongs_to :client_deployment
  belongs_to :installed_by, class_name: 'User', optional: true

  validates :installation_name, presence: true
  validates :client_deployment_id, presence: true

  scope :ordered, -> { order(installed_at: :desc) }
end

# frozen_string_literal: true

class DeploymentNetwork < ApplicationRecord
  belongs_to :client_deployment
  belongs_to :installed_by, class_name: 'User', optional: true

  validates :network_type, presence: true
  validates :client_deployment_id, presence: true

  scope :ordered, -> { order(installed_at: :desc) }
end

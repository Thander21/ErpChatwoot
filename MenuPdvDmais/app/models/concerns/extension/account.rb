module Extension
  module Account
    extend ActiveSupport::Concern

    included do
      has_many :kanban_columns, class_name: 'KanbanColumn', dependent: :destroy
      has_many :kanban_cards, class_name: 'KanbanCard', dependent: :destroy
      has_many :client_deployments, class_name: 'ClientDeployment', dependent: :destroy
    end
  end
end

Account.include(Extension::Account)

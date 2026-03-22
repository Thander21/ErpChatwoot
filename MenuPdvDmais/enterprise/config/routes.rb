namespace :enterprise, defaults: { format: 'json' } do
  namespace :api do
    namespace :v1 do
      resources :accounts do
        resources :kanban_columns, only: [:index, :show, :create, :update, :destroy]
        resources :kanban_cards, only: [:index, :show, :create, :update, :destroy] do
          collection do
            post :sync_companies
            post :cleanup_companies
            get :companies
            get :contacts_by_company
            get :archived_report
            get :tarefas_board
          end
          member do
            post :move
            post :archive
          end
        end

        # Módulo: Controle de Implantação
        resources :client_deployments, only: [:index, :show, :create, :update, :destroy] do
          resources :deployment_activities, only: [:index, :create, :update, :destroy]
          resources :deployment_systems, only: [:index, :create, :update, :destroy]
          resources :deployment_trainings, only: [:index, :create, :update, :destroy]
          resources :deployment_installations, only: [:index, :create, :update, :destroy]
          resources :deployment_hardwares, only: [:index, :create, :update, :destroy]
          resources :deployment_networks, only: [:index, :create, :update, :destroy]
        end

        resources :custom_contacts, only: [:index, :update, :destroy]
        
        resources :companies, only: [:index] do
          collection do
            post :validate_agent
            post :register_visit
          end
        end

        post 'telegram/webhook', to: 'telegram_events#process_payload'
      end
    end
  end
end

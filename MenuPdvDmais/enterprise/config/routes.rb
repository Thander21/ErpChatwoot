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
      end
    end
  end
end

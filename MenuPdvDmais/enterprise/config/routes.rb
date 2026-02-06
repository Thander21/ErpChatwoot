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
          end
          member do
            post :move
          end
        end
      end
    end
  end
end

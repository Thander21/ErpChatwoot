Rails.application.routes.draw do
  if ChatwootApp.enterprise?
    namespace :enterprise, defaults: { format: 'json' } do
      namespace :api do
        namespace :v1 do
          resources :accounts do
            resources :kanban_cards, only: [:index, :show, :create, :update, :destroy] do
              member do
                post :move
              end
            end
          end
        end
      end
    end
  end
end

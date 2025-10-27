# config/routes.rb
Rails.application.routes.draw do
  scope defaults: { format: :json } do
    # Alias “corto” fuera del namespace:
    post 'auth/login',    to: 'api/v1/auth#login'
    post 'auth/register', to: 'api/v1/auth#register'
    get  'auth/me',       to: 'api/v1/auth#me'

    namespace :api do
      namespace :v1 do
        # Auth real (también accesible por /api/v1/...)
        post 'auth/login',    to: 'auth#login'
        post 'auth/register', to: 'auth#register'
        get  'auth/me',       to: 'auth#me'

        resources :tramites do
          patch :update_estado, on: :member
          get :siguientes_estados, on: :member
          post :solicitar, on: :collection
          resources :historico_estados, only: :index
        end

        resources :historico_estados, only: :index
        resources :consultors
        resources :estado_tramites
        resources :clientes

        resources :tipo_tramites do
          resources :version_flujos, only: [:index, :create, :show, :destroy], shallow: true
        end

        resources :agenda_consultors, only: [:index, :show, :create]

        resources :version_flujos, only: [] do
          resources :transicion_flujos, only: [:index, :create, :destroy], shallow: true
        end
      end
    end
  end
end

# config/routes.rb
Rails.application.routes.draw do
  # Responder JSON por defecto (útil si es API-only)
  scope defaults: { format: :json } do

    # Recurso principal: Tramites
    resources :tramites do
      patch :update_estado, on: :member
      resources :historico_estados, only: :index   # /tramites/:tramite_id/historico_estados
    end

    # Auditoría global (opcional)
    resources :historico_estados, only: :index     # /historico_estados

    # ABMs de soporte
    resources :consultors          # full CRUD: index show create update destroy
    resources :tipo_tramites       # full CRUD: index show create update destroy

    # Agenda consultores (como lo tenías)
    resources :agenda_consultors, only: [:index, :show, :create]
  end
end

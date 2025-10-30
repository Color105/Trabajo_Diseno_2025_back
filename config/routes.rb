# config/routes.rb
Rails.application.routes.draw do
  # Responder JSON por defecto (útil si es API-only)
  scope defaults: { format: :json } do
    # ---------- Auth ----------
    post "/auth/login",    to: "auth#login"
    post "/auth/register", to: "auth#register"
    get  "/auth/me",       to: "auth#me"

    # ---------- Recurso principal: Tramites ----------
    resources :tramites do
      # Acción custom para transición de estado + opcional monto
      patch :update_estado, on: :member

      # Histórico anidado por trámite: /tramites/:tramite_id/historico_estados
      resources :historico_estados, only: :index
    end

    # Auditoría global (opcional): /historico_estados
    resources :historico_estados, only: :index

    # ---------- ABMs de soporte ----------
    resources :consultors          # full CRUD

    # --- ¡¡AQUÍ ESTÁ EL CAMBIO!! ---
    # Se expande tipo_tramites para incluir sus versiones y circuitos
    resources :tipo_tramites do
      resources :versions, path: 'versiones', shallow: true do
        resources :transicion_posibles, path: 'transiciones', only: [:create, :destroy]
        member do
          post 'clonar'
          post 'activar'
        end
      end
    end
    # --- FIN DEL CAMBIO ---

    resources :estado_tramites     # full CRUD
    resources :clientes            # full CRUD

    # ---------- Agenda consultores ----------
    resources :agenda_consultors, only: [:index, :show, :create]
  end
end
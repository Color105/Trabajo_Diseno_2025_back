# config/routes.rb
Rails.application.routes.draw do
  # Responder JSON por defecto (API)
  scope defaults: { format: :json } do
    # ---------- Auth ----------
    post "/auth/login",    to: "auth#login"
    post "/auth/register", to: "auth#register"
    get  "/auth/me",       to: "auth#me"

    # ---------- Tramites ----------
    resources :tramites do
      # transición de estado + opcional monto
      patch :update_estado, on: :member

      # histórico anidado por trámite: /tramites/:tramite_id/historico_estados
      resources :historico_estados, only: :index

      # documentos asociados al trámite
      resources :tramite_documentaciones,
                controller: :tramite_documentacion,
                path: "documentos",
                only: [:index, :create, :destroy]
    end

    # Auditoría global (opcional): /historico_estados
    resources :historico_estados, only: :index

    # ---------- ABMs de soporte ----------
    resources :consultors          # full CRUD
    resources :documentaciones     # tipos de documentación
    resources :estado_tramites     # full CRUD
    resources :clientes            # full CRUD

    # ---------- TipoTramites + Versiones + Transiciones ----------
    resources :tipo_tramites do
      # (opcional) asignar precio simple directo al tipo (ruta vieja, si aún la usás)
      post :asignar_precio, on: :member

      resources :versions, path: "versiones", shallow: true do
        resources :transicion_posibles,
                  path: "transiciones",
                  only: [:create, :destroy]

        member do
          post "clonar"
          post "activar"
        end
      end
    end

    # ---------- Listas de Precios ----------
    resources :lista_precios do
      member do
        patch :baja          # baja lógica de la lista
        get   :detalles      # devuelve los DetallePrecioTipoTramite de esa lista
        post  :asignar_precio # asignar/actualizar precio para un tipo_tramite en esa lista
      end
    end

    # ---------- Agenda consultores ----------
    resources :agenda_consultors, only: [:index, :show, :create]
  end
end

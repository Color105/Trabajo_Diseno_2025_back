# frozen_string_literal: true

class ClientesController < ApplicationController
  # Asumo que :authenticate_request! está en ApplicationController
  
  # Solo los admins pueden gestionar clientes
  before_action -> { authorize_role!('admin') }
  
  # Carga el @cliente para las acciones comunes
  before_action :set_cliente, only: [:show, :update, :destroy]

  # GET /clientes
  # Lista todos los clientes, ordenados por nombre.
  def index
    @clientes = Cliente.all.order(:nombre_apellido_cliente)
    render json: @clientes
  end

  # GET /clientes/:id
  # Muestra un cliente específico.
  def show
    render json: @cliente
  end

  # POST /clientes
  # Crea un nuevo cliente.
  def create
    @cliente = Cliente.new(cliente_params)

    # --- Manejo del User (CRÍTICO) ---
    # Asumimos que el admin también crea el 'User' (login) para este cliente.
    # El 'user_id' es obligatorio según tu modelo 'cliente.rb'.
    
    # 1. Crear el User
    # Usamos el CUIT como contraseña por defecto.
    default_password = cliente_params[:cuit_cliente]
    user = User.new(
      email: cliente_params[:mail_cliente],
      password: default_password,
      password_confirmation: default_password,
      role: :cliente
    )

    unless user.save
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      return
    end

    # 2. Asociar el User al Cliente y guardar
    @cliente.user = user
    if @cliente.save
      render json: @cliente, status: :created
    else
      # Si falla el cliente, borramos el user que acabamos de crear
      user.destroy 
      render json: { errors: @cliente.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  # PATCH /clientes/:id
  # Actualiza un cliente existente.
  def update
    if @cliente.update(cliente_params)
      render json: @cliente
    else
      render json: { errors: @cliente.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /clientes/:id
  # Elimina un cliente.
  def destroy
    # El 'dependent: :restrict_with_error' en tu modelo 'cliente.rb'
    # prevendrá la eliminación si hay trámites asociados y devolverá un error.
    if @cliente.destroy
      # Borramos también el User asociado
      @cliente.user.destroy if @cliente.user
      head :no_content 
    else
      render json: { errors: @cliente.errors.full_messages.presence || ["No se pudo eliminar el cliente."] }, status: :unprocessable_entity
    end
  end

  private

    def set_cliente
      @cliente = Cliente.find(params[:id])
    end
    
    # Parámetros fuertes (Strong Parameters)
    # Coinciden con tu modelo 'cliente.rb' y tu frontend 'ABMClientes.jsx'
    def cliente_params
      params.require(:cliente).permit(
        :nombre_apellido_cliente, # <--- Campo unificado
        :mail_cliente,
        :cuit_cliente,
        :direccion_cliente,
        :telefono_cliente,
        :fecha_hora_baja_cliente # Permitir dar de baja (ej: update)
        # :user_id no se permite, se maneja en 'create'
      )
    end
end

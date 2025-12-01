# frozen_string_literal: true

class ClientesController < ApplicationController
  before_action -> { authorize_role!('admin') }
  before_action :set_cliente, only: [:show, :update, :destroy]

  # GET /clientes
  def index
    @clientes = Cliente.all.order(:nombre_apellido_cliente)
    render json: @clientes
  end

  # GET /clientes/:id
  def show
    render json: @cliente
  end

  # POST /clientes
  def create
    @cliente = Cliente.new(cliente_params)

    if @cliente.save
      render json: @cliente, status: :created
    else
      # Devolvemos errores completos para debugging en frontend
      render json: { errors: @cliente.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH /clientes/:id
  def update
    if @cliente.update(cliente_params)
      render json: @cliente
    else
      render json: { errors: @cliente.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /clientes/:id
  #
  # Solo permite eliminar el cliente si NO tiene trámites activos
  # en estados no finales. Es decir, si tiene trámites cuyo estado
  # NO sea Terminado / Suspendido / Cancelado, se bloquea la eliminación.
  #
  def destroy
    if @cliente.tiene_tramites_activos_no_finales?
      render json: {
        error: 'No se puede eliminar el cliente porque tiene trámites activos que aún no están finalizados. ' \
               'Solo se permite eliminar clientes cuyos trámites estén en estado Terminado, Suspendido o Cancelado.'
      }, status: :unprocessable_entity
    elsif @cliente.destroy
      head :no_content
    else
      render json: { errors: @cliente.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

    def set_cliente
      @cliente = Cliente.find(params[:id])
    end

    # Strong Parameters actualizados
    def cliente_params
      params.require(:cliente).permit(
        :nombre_apellido_cliente,
        :mail_cliente,
        :cuit_cliente,
        :direccion_cliente,
        :telefono_cliente,
        :fecha_hora_baja_cliente,
        # Permitimos atributos anidados para el modelo User
        user_attributes: [:id, :name, :email, :password, :password_confirmation, :role]
      )
    end
end

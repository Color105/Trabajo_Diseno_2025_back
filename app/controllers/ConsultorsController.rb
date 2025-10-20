class ConsultorsController < ApplicationController

  # GET /consultors
  def index
    @consultors = Consultor.all
    render json: @consultors
  end

  # GET /consultors/:id
  def show
    @consultor = Consultor.find(params[:id])
    render json: @consultor
  end

  # POST /consultors
  def create
    @consultor = Consultor.new(consultor_params)

    if @consultor.save
      render json: @consultor, status: :created
    else
      render json: @consultor.errors, status: :unprocessable_entity
    end
  end

  private
    # Parámetros fuertes
    def consultor_params
      params.require(:consultor).permit(:nombre, :email)
    end
end
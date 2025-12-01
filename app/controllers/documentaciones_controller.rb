# app/controllers/documentaciones_controller.rb
# frozen_string_literal: true

class DocumentacionesController < ApplicationController
  # GET /documentaciones
  def index
    docs = Documentacion.order(:cod_documentacion)
    render json: docs, status: :ok
  end

  # POST /documentaciones
  def create
    doc = Documentacion.new(documentacion_params)
    if doc.save
      render json: doc, status: :created
    else
      render json: { errors: doc.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /documentaciones/:id
  def update
    doc = Documentacion.find(params[:id])
    if doc.update(documentacion_params)
      render json: doc, status: :ok
    else
      render json: { errors: doc.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /documentaciones/:id
  def destroy
    doc = Documentacion.find(params[:id])
    doc.destroy
    head :no_content
  end

  private

  def documentacion_params
    params.require(:documentacion).permit(:cod_documentacion, :nombre_documentacion)
  end
end

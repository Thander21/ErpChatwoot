class KanbanCardsController < ApplicationController
  include EnterpriseHelper

  before_action :set_account
  before_action :set_kanban_card, only: [:show, :update, :destroy]

  def index
    @kanban_cards = @account.kanban_cards.includes(:conversation, :contact).ordered

    # Filtrar por coluna se especificado
    @kanban_cards = @kanban_cards.by_column(params[:column_id]) if params[:column_id].present?

    render json: @kanban_cards, include: [:conversation, :contact]
  end

  def show
    render json: @kanban_card, include: [:conversation, :contact]
  end

  def create
    @kanban_card = @account.kanban_cards.build(kanban_card_params)

    if @kanban_card.save
      render json: @kanban_card, include: [:conversation, :contact], status: :created
    else
      render json: @kanban_card.errors, status: :unprocessable_entity
    end
  end

  def update
    if @kanban_card.update(kanban_card_params)
      render json: @kanban_card, include: [:conversation, :contact]
    else
      render json: @kanban_card.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @kanban_card.destroy
    head :no_content
  end

  def move
    @kanban_card = @account.kanban_cards.find(params[:id])

    # Reordenar cards na coluna de destino
    destination_column = params[:kanban_column_id]
    position = params[:position] || 0

    # Mover o card para a nova posição
    ActiveRecord::Base.transaction do
      # Remover da posição atual
      @account.kanban_cards.where('position > ?', @kanban_card.position)
                             .where(kanban_column_id: @kanban_card.kanban_column_id)
                             .update_all('position = position - 1')

      # Inserir na nova posição
      @account.kanban_cards.where('position >= ?', position)
                             .where(kanban_column_id: destination_column)
                             .update_all('position = position + 1')

      @kanban_card.update!(
        kanban_column_id: destination_column,
        position: position
      )
    end

    render json: @kanban_card, include: [:conversation, :contact]
  end

  private

  def set_account
    @account = current_account
  end

  def set_kanban_card
    @kanban_card = @account.kanban_cards.find(params[:id])
  end

  def kanban_card_params
    params.require(:kanban_card).permit(
      :title,
      :description,
      :kanban_column_id,
      :conversation_id,
      :contact_id,
      :position,
      :due_date,
      :priority,
      custom_attributes: {}
    )
  end
end

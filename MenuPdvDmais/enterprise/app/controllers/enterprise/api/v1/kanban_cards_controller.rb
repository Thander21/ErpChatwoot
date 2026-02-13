class Enterprise::Api::V1::KanbanCardsController < Api::BaseController
  include EnterpriseHelper

  before_action :set_account
  before_action :set_kanban_card, only: [:show, :update, :destroy]

  def index
    @kanban_cards = @account.kanban_cards.active.includes(:conversation, :contact, :company, :assignee, :archived_by).ordered

    # Filtrar por coluna se especificado
    @kanban_cards = @kanban_cards.by_column(params[:column_id]) if params[:column_id].present?

    render json: @kanban_cards, include: [:conversation, :contact, :company, :assignee]
  end

  def show
    render json: @kanban_card, include: [:conversation, :contact, :company, :assignee]
  end

  def create
    @kanban_card = @account.kanban_cards.build(kanban_card_params)

    if @kanban_card.save
      render json: @kanban_card, include: [:conversation, :contact, :company, :assignee], status: :created
    else
      render json: @kanban_card.errors, status: :unprocessable_entity
    end
  end

  def update
    if @kanban_card.update(kanban_card_params)
      render json: @kanban_card, include: [:conversation, :contact, :company, :assignee]
    else
      render json: @kanban_card.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @kanban_card.destroy
    head :no_content
  end

  def archive
    @kanban_card = @account.kanban_cards.find(params[:id])
    if @kanban_card.update(archived_at: Time.current, archived_by: current_user)
      render json: @kanban_card
    else
      render json: @kanban_card.errors, status: :unprocessable_entity
    end
  end

  def archived_report
    # Default to current month/year if not provided
    date = Date.current
    if params[:month].present? && params[:year].present?
      begin
        date = Date.new(params[:year].to_i, params[:month].to_i, 1)
      rescue ArgumentError
        # Fallback to current date on invalid input
      end
    end

    start_date = date.beginning_of_month
    end_date = date.end_of_month

    # Query para buscar arquivados OU deletados no período
    @archived_cards = @account.kanban_cards.all_with_deleted
                              .where(
                                "(archived_at BETWEEN :start AND :end) OR (deleted_at BETWEEN :start AND :end)",
                                start: start_date, end: end_date
                              )
                              .includes(:conversation, :contact, :company, :assignee, :archived_by, :deleted_by)
                              .order(Arel.sql('COALESCE(deleted_at, archived_at) DESC'))

    render json: @archived_cards, include: [:conversation, :contact, :company, :assignee, :archived_by, :deleted_by]
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

    render json: @kanban_card, include: [:conversation, :contact, :company, :assignee]
  end

  # SYNC BRUTAL DE EMPRESAS
  # Varre contatos com company_name e garante que exista a Company e o vínculo
  def sync_companies
    count = 0
    # Itera sobre contatos que tem nome de empresa no jsonb
    @account.contacts.where("additional_attributes->>'company_name' IS NOT NULL AND additional_attributes->>'company_name' <> ''").find_each do |contact|
      company_name = contact.additional_attributes['company_name'].strip
      next if company_name.blank?

      # Busca ou Cria a Empresa
      company = @account.companies.find_or_create_by(name: company_name)
      
      # Atualiza o contato se não estiver vinculado
      if contact.company_id != company.id
         contact.update(company_id: company.id)
         count += 1
      end
    end
    
    render json: { message: "#{count} contatos sincronizados com empresas." }
  end

  # LIMPEZA DE EMPRESAS VAZIAS
  # Remove empresas que não têm contatos vinculados
  def cleanup_companies
    deleted = 0
    # Left join para achar companies sem contacts
    # Nota: Precisamos garantir que não delete empresas que tenham outros dados importantes. 
    # Assumindo que empresa sem contato é "lixo" de digitação.
    @account.companies.left_joins(:contacts).where(contacts: { id: nil }).find_each do |company|
       company.destroy
       deleted += 1
    end
    
    render json: { message: "#{deleted} empresas vazias removidas." }
  end

  # Mantendo contacts_by_company pois é util para o modal filtrar
  # LISTAGEM DE CONTATOS POR EMPRESA
  def contacts_by_company
    if params[:company_id].present?
      contacts = @account.contacts
                         .where(company_id: params[:company_id])
                         .order(:name)
      
      render json: contacts.select(:id, :name, :email, :phone_number)
    else
      render json: []
    end
  end

  private

  def set_account
    @account = Account.find(params[:account_id])
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
      :company_id,
      :assignee_id,
      :position,
      :due_date,
      :priority,
      custom_attributes: {}
    )
  end
end

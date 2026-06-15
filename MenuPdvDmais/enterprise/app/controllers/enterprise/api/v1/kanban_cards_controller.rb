class Enterprise::Api::V1::KanbanCardsController < Api::BaseController
  include EnterpriseHelper

  before_action :set_account
  before_action :set_kanban_card, only: [:show, :update, :destroy]

  def index
    @kanban_cards = @account.kanban_cards.active.includes(:conversation, :contact, :company, :assignee, :implementer, :archived_by).ordered

    # Filtrar por coluna se especificado
    @kanban_cards = @kanban_cards.by_column(params[:column_id]) if params[:column_id].present?

    render json: @kanban_cards, include: [:conversation, :contact, :company, :assignee, :implementer]
  end

  def show
    render json: @kanban_card, include: [:conversation, :contact, :company, :assignee, :implementer]
  end

  def create
    @kanban_card = @account.kanban_cards.build(kanban_card_params)

    if @kanban_card.save
      render json: @kanban_card, include: [:conversation, :contact, :company, :assignee, :implementer], status: :created
    else
      render json: @kanban_card.errors, status: :unprocessable_entity
    end
  end

  def update
    if @kanban_card.update(kanban_card_params)
      render json: @kanban_card, include: [:conversation, :contact, :company, :assignee, :implementer]
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
                              .includes(:conversation, :contact, :company, :assignee, :implementer, :archived_by, :deleted_by)
                              .order(Arel.sql('COALESCE(deleted_at, archived_at) DESC'))

    render json: @archived_cards, include: [:conversation, :contact, :company, :assignee, :implementer, :archived_by, :deleted_by]
  end

  # Endpoint otimizado para o Kanban Tarefas
  def tarefas_board
    # Permissão básica (Apenas ler conversas da conta)
    # Busca todas as conversas pertinentes sem paginar, usando filtros direto no banco.
    # Pendentes (2), Abertas (0), Adiadas (3), Resolvidas (1) em até 7 dias
    seven_days_ago = 7.days.ago
    
    @conversations = @account.conversations
                             .where("status IN (0, 2, 3) OR (status = 1 AND updated_at >= ?)", seven_days_ago) # resolved within 7 days
                             .includes(:contact, :assignee, messages: [:attachments])

    # Serialização customizada para entregar um payload menor
    # e compatível com as expectativas atuais do front-end.
    # Evita instanciar o ConversationSerializer do backend original se ele for muito pesado.
    
    payload = @conversations.map do |conv|
      {
        id: conv.display_id, # Frontend expects display_id as id
        status: conv.status,
        snoozed_until: conv.snoozed_until,
        updated_at: conv.updated_at.to_time.to_i, # Match original API format (seconds since epoch)
        priority: conv.priority,
        meta: {
          sender: conv.contact.as_json(only: [:id, :name, :email, :phone_number, :additional_attributes]),
          assignee: conv.assignee.as_json(only: [:id, :name, :email, :available_name, :thumbnail]),
          # Extraímos a empresa do Additional Attributes ou como for estruturado. Se for outra lógica, ajustamos.
          company: conv.contact&.company&.as_json(only: [:id, :name])
        },
        # Ultima mensagem p/ description
        last_non_activity_message: extract_last_message(conv)
      }
    end

    render json: { payload: payload }
  end

  def extract_last_message(conversation)
    # Filter in memory to avoid N+1 queries. 'messages' is already eager loaded.
    last_msg = conversation.messages.reject(&:activity?).max_by(&:created_at)
    last_msg&.content || "Mensagem sem conteúdo"
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

    render json: @kanban_card, include: [:conversation, :contact, :company, :assignee, :implementer]
  end

  # SYNC BRUTAL DE EMPRESAS
  # Varre contatos com company_name e garante que exista a Company e o vínculo
  def sync_companies
    count = 0
    exceptions = %w[da de di do o a e com]

    # Itera sobre contatos que tem nome de empresa no jsonb
    @account.contacts.where("additional_attributes->>'company_name' IS NOT NULL AND additional_attributes->>'company_name' <> ''").find_each do |contact|
      raw_name = contact.additional_attributes['company_name'].to_s.strip
      next if raw_name.blank?

      # Padronização do nome da empresa
      company_name = raw_name.downcase.split.each_with_index.map do |word, index|
        (index == 0 || !exceptions.include?(word)) ? word.capitalize : word
      end.join(' ')

      # Busca ou Cria a Empresa
      company = @account.companies.find_or_create_by(name: company_name)
      
      # Atualiza o contato se não estiver vinculado ou se o nome foi padronizado
      attrs_to_update = {}
      attrs_to_update[:company_id] = company.id if contact.company_id != company.id
      
      if raw_name != company_name
        new_attributes = contact.additional_attributes.merge('company_name' => company_name)
        attrs_to_update[:additional_attributes] = new_attributes
      end

      if attrs_to_update.present?
        contact.update(attrs_to_update)
        count += 1
      end
    end
    
    render json: { message: "#{count} contatos sincronizados/padronizados com empresas." }
  end

  # LIMPEZA DE EMPRESAS VAZIAS
  # Remove empresas que não têm contatos vinculados
  def cleanup_companies
    deleted = 0
    # Left join para achar companies sem contacts
    # Nota: Precisamos garantir que não delete empresas que tenham outros dados importantes. 
    # Assumindo que empresa sem contato é "lixo" de digitação.
    @account.companies.left_joins(:contacts).where(contacts: { id: nil }).find_each do |company|
       # Apaga todo o histórico (Ficha do Cliente) antes de apagar a empresa
       ClientDeployment.where(company_id: company.id).destroy_all
       
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
      :implementer_id,
      :position,
      :due_date,
      :priority,
      custom_attributes: {}
    )
  end
end

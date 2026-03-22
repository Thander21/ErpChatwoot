# frozen_string_literal: true

class Enterprise::TelegramBotService
  attr_reader :account, :params, :chat_id, :text, :user_id, :username

  BOT_TOKEN = ENV.fetch('TELEGRAM_BOT_TOKEN', '')
  API_URL = "https://api.telegram.org/bot#{BOT_TOKEN}"

  def initialize(account, params)
    @account = account
    @params = params
    @chat_id = params.dig('message', 'chat', 'id') || params.dig('callback_query', 'message', 'chat', 'id')
    @text = params.dig('message', 'text')
    @user_id = params.dig('message', 'from', 'id') || params.dig('callback_query', 'from', 'id')
    @username = params.dig('message', 'from', 'username') || params.dig('callback_query', 'from', 'username')
  end

  def perform
    return unless chat_id && (text || params['callback_query'])

    if params['callback_query']
      handle_callback_query
    elsif text == '/start' || text == '/visita'
      start_flow
    else
      continue_flow
    end
  end

  private

  def start_flow
    agent = ::TelegramAgent.find_by(telegram_user_id: user_id, account: account)
    
    if agent
      clear_state
      ask_company_name
    else
      set_state(:awaiting_email)
      send_message("Olá! Para iniciar, informe seu e-mail de agente do Chatwoot.")
    end
  end

  def continue_flow
    case get_state
    when :awaiting_email
      validate_and_link_agent
    when :awaiting_company_name
      search_and_list_companies
    when :awaiting_description
      register_final_visit
    else
      send_message("Comando não reconhecido. Use /visita para iniciar.")
    end
  end

  def handle_callback_query
    data = params.dig('callback_query', 'data')
    
    if data.start_with?('company_')
      company_id = data.split('_').last
      set_state_data(:company_id, company_id)
      ask_service_type
    elsif data.start_with?('service_')
      service_type = data.split('_').last
      set_state_data(:service_type, service_type)
      set_state(:awaiting_description)
      send_message("Descreva o serviço realizado (ex: 'Backup do banco e atualização de versão'):")
    end
  end

  # --- Ações de Fluxo ---

  def validate_and_link_agent
    email = text.strip.downcase
    user = User.find_by(email: email)

    if user && user.account_users.exists?(account_id: account.id)
      ::TelegramAgent.create!(
        telegram_user_id: user_id,
        user: user,
        account: account
      )
      clear_state
      send_message("Agente vinculado com sucesso! ✅")
      ask_company_name
    else
      send_message("Acesso não permitido. E-mail não encontrado ou não é agente desta conta. ❌")
    end
  end

  def ask_company_name
    set_state(:awaiting_company_name)
    send_message("Qual o nome da empresa que deseja cadastrar a visita?")
  end

  def search_and_list_companies
    query = text.strip
    companies = account.companies.where("name ILIKE ?", "%#{query}%").limit(5)

    if companies.empty?
      send_message("Nenhuma empresa encontrada com '#{query}'. Tente outro nome:")
    else
      buttons = companies.map do |c|
        [{ text: c.name, callback_data: "company_#{c.id}" }]
      end
      send_message("Selecione a empresa:", buttons)
    end
  end

  def ask_service_type
    buttons = [
      [{ text: "🎓 Treinamento", callback_data: "service_treinamento" }],
      [{ text: "🛠️ Implantação", callback_data: "service_implantação" }],
      [{ text: "💻 Sistema", callback_data: "service_sistema" }],
      [{ text: "🔌 Hardware", callback_data: "service_hardware" }],
      [{ text: "🌐 Rede", callback_data: "service_rede" }]
    ]
    send_message("Selecione o tipo de serviço:", buttons)
  end

  def register_final_visit
    state_data = get_all_state_data
    agent = ::TelegramAgent.find_by(telegram_user_id: user_id, account: account)

    # Reutiliza a lógica do CompaniesController
    controller = Enterprise::Api::V1::CompaniesController.new
    # Mockando params para o controller reutilizar
    reg_params = {
      telegram_user_id: user_id,
      company_id: state_data[:company_id],
      service_type: state_data[:service_type],
      description: text,
      account_id: account.id
    }
    
    # Chama o método de registro (ou refatora para um serviço compartilhado se preferir)
    # Por agora, vamos injetar os dados diretamente já que o controller é complexo
    deployment = account.client_deployments.find_or_create_by!(
      company_id: state_data[:company_id],
      title: "Ficha Técnica - #{Time.current.strftime('%d/%m/%Y')} (Via Telegram)",
      account_id: account.id
    )

    case state_data[:service_type]
    when 'treinamento'
      DeploymentTraining.create!(client_deployment: deployment, trained_by: agent.user, trained_at: Time.current, notes: text, system_name: "Geral", contact: deployment.company.contacts.first)
      DeploymentActivity.create!(client_deployment: deployment, user: agent.user, activity_type: :training, description: "Treinamento registrado via Telegram: #{text}", occurred_at: Time.current)
    when 'implantação'
      DeploymentInstallation.create!(client_deployment: deployment, installed_by: agent.user, installed_at: Time.current, notes: text, installation_name: "Via Telegram")
      DeploymentActivity.create!(client_deployment: deployment, user: agent.user, activity_type: :support, description: "Implantação registrada via Telegram: #{text}", occurred_at: Time.current)
    when 'sistema'
      DeploymentSystem.create!(client_deployment: deployment, installed_by: agent.user, installed_at: Time.current, notes: text, system_name: "Geral")
      DeploymentActivity.create!(client_deployment: deployment, user: agent.user, activity_type: :installation, description: "Registro de Sistema via Telegram: #{text}", occurred_at: Time.current)
    when 'hardware'
      DeploymentHardware.create!(client_deployment: deployment, installed_by: agent.user, installed_at: Time.current, notes: text, hardware_name: "Equipamento")
      DeploymentActivity.create!(client_deployment: deployment, user: agent.user, activity_type: :support, description: "Hardware registrados via Telegram: #{text}", occurred_at: Time.current)
    when 'rede'
      DeploymentNetwork.create!(client_deployment: deployment, installed_by: agent.user, installed_at: Time.current, notes: text, network_type: "Infraestrutura")
      DeploymentActivity.create!(client_deployment: deployment, user: agent.user, activity_type: :support, description: "Rede registrada via Telegram: #{text}", occurred_at: Time.current)
    end

    clear_state
    send_message("Visita registrada com sucesso na ficha do cliente! 🚀✅")
  end

  # --- Helpers do Telegram ---

  def send_message(message, inline_keyboard = nil)
    payload = {
      chat_id: chat_id,
      text: message,
      parse_mode: 'HTML'
    }
    payload[:reply_markup] = { inline_keyboard: inline_keyboard } if inline_keyboard

    RestClient.post(
      "#{API_URL}/sendMessage",
      payload.to_json,
      { content_type: :json, accept: :json }
    )
  end

  # --- Gerenciamento de Estado ---

  def set_state(state)
    Rails.cache.write("tg_state_#{user_id}", state, expires_in: 1.hour)
  end

  def get_state
    Rails.cache.read("tg_state_#{user_id}")&.to_sym
  end

  def set_state_data(key, value)
    data = get_all_state_data
    data[key] = value
    Rails.cache.write("tg_data_#{user_id}", data, expires_in: 1.hour)
  end

  def get_all_state_data
    Rails.cache.read("tg_data_#{user_id}") || {}
  end

  def clear_state
    Rails.cache.delete("tg_state_#{user_id}")
    Rails.cache.delete("tg_data_#{user_id}")
  end
end

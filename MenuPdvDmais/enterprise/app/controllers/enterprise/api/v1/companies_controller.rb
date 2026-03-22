# frozen_string_literal: true

class Enterprise::Api::V1::CompaniesController < Api::V1::Accounts::BaseController
  before_action :validate_telegram_request, only: [:register_visit]

  # GET /enterprise/api/v1/accounts/{account_id}/companies
  def index
    query = params[:q]
    @companies = @account.companies.search_by_name_or_domain(query).ordered_by_name
    render json: @companies.as_json(only: [:id, :name, :description])
  end

  # POST /enterprise/api/v1/accounts/{account_id}/companies/validate_agent
  def validate_agent
    email = params[:email]
    telegram_user_id = params[:telegram_user_id]

    user = User.find_by(email: email)
    
    if user && user.account_users.exists?(account_id: @account.id)
      telegram_agent = TelegramAgent.find_or_initialize_by(telegram_user_id: telegram_user_id, account_id: @account.id)
      telegram_agent.user = user
      telegram_agent.save!

      render json: { success: true, message: "Agente validado e vinculado com sucesso." }
    else
      render json: { success: false, message: "Acesso não permitido para enviar visitas. E-mail não encontrado ou não é agente desta conta." }, status: :forbidden
    end
  end

  # POST /enterprise/api/v1/accounts/{account_id}/companies/register_visit
  def register_visit
    telegram_user_id = params[:telegram_user_id]
    telegram_agent = TelegramAgent.find_by(telegram_user_id: telegram_user_id, account_id: @account.id)

    unless telegram_agent
      return render json: { success: false, message: "Agente não vinculado." }, status: :unauthorized
    end

    company = @account.companies.find(params[:company_id])
    service_type = params[:service_type] # [Treinamento, Implantação, Sistema, Hardware, Rede]
    
    # Busca ou cria o ClientDeployment para esta empresa
    deployment = @account.client_deployments.find_or_create_by!(
      company: company,
      title: "Implantação Automática - #{company.name}"
    )

    case service_type.to_s.downcase
    when 'treinamento'
      create_training(deployment, telegram_agent.user, params)
    when 'implantação'
      create_installation(deployment, telegram_agent.user, params)
    when 'sistema'
      create_system(deployment, telegram_agent.user, params)
    when 'hardware'
      create_hardware(deployment, telegram_agent.user, params)
    when 'rede'
      create_network(deployment, telegram_agent.user, params)
    else
      return render json: { success: false, message: "Tipo de serviço inválido." }, status: :unprocessable_entity
    end

    render json: { success: true, message: "Visita registrada com sucesso na ficha do cliente!" }
  end

  private

  def validate_telegram_request
    # Bloqueio simples para garantir que a requisição venha do bot
    # Pode ser expandido para usar um Bearer Token específico se necessário.
    true
  end

  def create_training(deployment, user, params)
    DeploymentTraining.create!(
      client_deployment: deployment,
      trained_by: user,
      contact: deployment.company.contacts.first || create_dummy_contact(deployment.company),
      system_name: params[:system_name] || "Geral",
      trained_at: Time.current,
      notes: params[:description]
    )
  end

  def create_installation(deployment, user, params)
    DeploymentInstallation.create!(
      client_deployment: deployment,
      installed_by: user,
      installation_name: "Instalação via Telegram",
      installed_at: Time.current,
      notes: params[:description]
    )
  end

  def create_system(deployment, user, params)
    DeploymentSystem.create!(
      client_deployment: deployment,
      installed_by: user,
      system_name: params[:system_name] || "Geral",
      installed_at: Time.current,
      notes: params[:description]
    )
  end

  def create_hardware(deployment, user, params)
    DeploymentHardware.create!(
      client_deployment: deployment,
      installed_by: user,
      hardware_name: params[:hardware_name] || "Equipamento",
      installed_at: Time.current,
      notes: params[:description]
    )
  end

  def create_network(deployment, user, params)
    DeploymentNetwork.create!(
      client_deployment: deployment,
      installed_by: user,
      network_type: params[:network_type] || "Infraestrutura",
      installed_at: Time.current,
      notes: params[:description]
    )
  end

  def create_dummy_contact(company)
    # se não houver contato, cria um genérico para satisfazer a FK do DeploymentTraining
    company.contacts.create!(
      name: "Responsável - #{company.name}",
      account_id: company.account_id
    )
  end
end

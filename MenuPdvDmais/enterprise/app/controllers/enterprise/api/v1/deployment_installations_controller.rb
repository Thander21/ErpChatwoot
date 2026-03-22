# frozen_string_literal: true

class Enterprise::Api::V1::DeploymentInstallationsController < Api::BaseController
  include EnterpriseHelper

  before_action :set_account
  before_action :set_deployment
  before_action :set_installation, only: [:update, :destroy]

  def index
    @installations = @deployment.deployment_installations.includes(:installed_by).ordered
    render json: @installations.as_json(include: { installed_by: { only: [:id, :name] } })
  end

  def create
    @installation = @deployment.deployment_installations.build(installation_params)
    @installation.installed_by = current_user if @installation.installed_by_id.blank?

    if @installation.save
      render json: @installation.as_json(include: { installed_by: { only: [:id, :name] } }), status: :created
    else
      render json: @installation.errors, status: :unprocessable_entity
    end
  end

  def update
    if @installation.update(installation_params)
      render json: @installation.as_json(include: { installed_by: { only: [:id, :name] } })
    else
      render json: @installation.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @installation.destroy
    head :no_content
  end

  private

  def set_account
    @account = Account.find(params[:account_id])
  end

  def set_deployment
    @deployment = @account.client_deployments.find(params[:client_deployment_id])
  end

  def set_installation
    @installation = @deployment.deployment_installations.find(params[:id])
  end

  def installation_params
    params.require(:deployment_installation).permit(
      :installation_name, :installed_at, :installed_by_id, :notes
    )
  end
end

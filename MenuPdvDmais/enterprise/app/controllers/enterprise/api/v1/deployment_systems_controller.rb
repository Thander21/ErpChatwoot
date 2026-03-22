# frozen_string_literal: true

class Enterprise::Api::V1::DeploymentSystemsController < Api::BaseController
  include EnterpriseHelper

  before_action :set_account
  before_action :set_deployment
  before_action :set_system, only: [:update, :destroy]

  def index
    @systems = @deployment.deployment_systems.includes(:installed_by).ordered
    render json: @systems.as_json(include: { installed_by: { only: [:id, :name] } })
  end

  def create
    @system = @deployment.deployment_systems.build(system_params)
    @system.installed_by = current_user if @system.installed_by_id.blank?

    if @system.save
      render json: @system.as_json(include: { installed_by: { only: [:id, :name] } }), status: :created
    else
      render json: @system.errors, status: :unprocessable_entity
    end
  end

  def update
    if @system.update(system_params)
      render json: @system.as_json(include: { installed_by: { only: [:id, :name] } })
    else
      render json: @system.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @system.destroy
    head :no_content
  end

  private

  def set_account
    @account = Account.find(params[:account_id])
  end

  def set_deployment
    @deployment = @account.client_deployments.find(params[:client_deployment_id])
  end

  def set_system
    @system = @deployment.deployment_systems.find(params[:id])
  end

  def system_params
    params.require(:deployment_system).permit(
      :system_name, :version, :installed_at, :installed_by_id, :notes
    )
  end
end

# frozen_string_literal: true

class Enterprise::Api::V1::DeploymentNetworksController < Api::BaseController
  include EnterpriseHelper

  before_action :set_account
  before_action :set_deployment
  before_action :set_network, only: [:update, :destroy]

  def index
    @networks = @deployment.deployment_networks.includes(:installed_by).ordered
    render json: @networks.as_json(include: { installed_by: { only: [:id, :name] } })
  end

  def create
    @network = @deployment.deployment_networks.build(network_params)
    @network.installed_by = current_user if @network.installed_by_id.blank?

    if @network.save
      render json: @network.as_json(include: { installed_by: { only: [:id, :name] } }), status: :created
    else
      render json: @network.errors, status: :unprocessable_entity
    end
  end

  def update
    if @network.update(network_params)
      render json: @network.as_json(include: { installed_by: { only: [:id, :name] } })
    else
      render json: @network.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @network.destroy
    head :no_content
  end

  private

  def set_account
    @account = Account.find(params[:account_id])
  end

  def set_deployment
    @deployment = @account.client_deployments.find(params[:client_deployment_id])
  end

  def set_network
    @network = @deployment.deployment_networks.find(params[:id])
  end

  def network_params
    params.require(:deployment_network).permit(
      :network_type, :infrastructure_details, :installed_at, :installed_by_id, :notes
    )
  end
end

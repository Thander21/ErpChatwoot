# frozen_string_literal: true

class Enterprise::Api::V1::DeploymentHardwaresController < Api::BaseController
  include EnterpriseHelper

  before_action :set_account
  before_action :set_deployment
  before_action :set_hardware, only: [:update, :destroy]

  def index
    @hardwares = @deployment.deployment_hardwares.includes(:installed_by).ordered
    render json: @hardwares.as_json(include: { installed_by: { only: [:id, :name] } })
  end

  def create
    @hardware = @deployment.deployment_hardwares.build(hardware_params)
    @hardware.installed_by = current_user if @hardware.installed_by_id.blank?

    if @hardware.save
      render json: @hardware.as_json(include: { installed_by: { only: [:id, :name] } }), status: :created
    else
      render json: @hardware.errors, status: :unprocessable_entity
    end
  end

  def update
    if @hardware.update(hardware_params)
      render json: @hardware.as_json(include: { installed_by: { only: [:id, :name] } })
    else
      render json: @hardware.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @hardware.destroy
    head :no_content
  end

  private

  def set_account
    @account = Account.find(params[:account_id])
  end

  def set_deployment
    @deployment = @account.client_deployments.find(params[:client_deployment_id])
  end

  def set_hardware
    @hardware = @deployment.deployment_hardwares.find(params[:id])
  end

  def hardware_params
    params.require(:deployment_hardware).permit(
      :hardware_name, :serial_number, :installed_at, :installed_by_id, :notes
    )
  end
end

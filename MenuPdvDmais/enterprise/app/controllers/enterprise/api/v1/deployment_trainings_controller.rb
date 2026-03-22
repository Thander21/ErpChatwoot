# frozen_string_literal: true

class Enterprise::Api::V1::DeploymentTrainingsController < Api::BaseController
  include EnterpriseHelper

  before_action :set_account
  before_action :set_deployment
  before_action :set_training, only: [:update, :destroy]

  def index
    @trainings = @deployment.deployment_trainings
                            .includes(:contact, :trained_by)
                            .ordered
    render json: @trainings.as_json(
      include: {
        contact: { only: [:id, :name, :phone_number] },
        trained_by: { only: [:id, :name] }
      }
    )
  end

  def create
    @training = @deployment.deployment_trainings.build(training_params)
    @training.trained_by = current_user if @training.trained_by_id.blank?

    if @training.save
      render json: @training.as_json(
        include: {
          contact: { only: [:id, :name, :phone_number] },
          trained_by: { only: [:id, :name] }
        }
      ), status: :created
    else
      render json: @training.errors, status: :unprocessable_entity
    end
  end

  def update
    if @training.update(training_params)
      render json: @training.as_json(
        include: {
          contact: { only: [:id, :name, :phone_number] },
          trained_by: { only: [:id, :name] }
        }
      )
    else
      render json: @training.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @training.destroy
    head :no_content
  end

  private

  def set_account
    @account = Account.find(params[:account_id])
  end

  def set_deployment
    @deployment = @account.client_deployments.find(params[:client_deployment_id])
  end

  def set_training
    @training = @deployment.deployment_trainings.find(params[:id])
  end

  def training_params
    params.require(:deployment_training).permit(
      :contact_id, :system_name, :trained_at, :trained_by_id, :duration_minutes, :notes
    )
  end
end

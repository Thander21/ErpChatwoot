# frozen_string_literal: true

class Enterprise::Api::V1::ClientDeploymentsController < Api::BaseController
  include EnterpriseHelper

  before_action :set_account
  before_action :set_deployment, only: [:show, :update, :destroy]

  def index
    @deployments = @account.client_deployments
                           .includes(:company, :contact, :assignee, :deployment_systems, :deployment_activities)
                           .ordered

    @deployments = @deployments.by_company(params[:company_id]) if params[:company_id].present?

    render json: @deployments.map { |d| deployment_json(d) }
  end

  def show
    render json: deployment_json(@deployment, full: true)
  end

  def create
    @deployment = @account.client_deployments.build(deployment_params)
    @deployment.assignee = current_user if @deployment.assignee_id.blank?

    if @deployment.save
      render json: deployment_json(@deployment), status: :created
    else
      render json: @deployment.errors, status: :unprocessable_entity
    end
  end

  def update
    if @deployment.update(deployment_params)
      render json: deployment_json(@deployment, full: true)
    else
      render json: @deployment.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @deployment.destroy
    head :no_content
  end

  private

  def set_account
    @account = Account.find(params[:account_id])
  end

  def set_deployment
    @deployment = @account.client_deployments.find(params[:id])
  end

  def deployment_params
    params.require(:client_deployment).permit(
      :title, :company_id, :contact_id, :assignee_id,
      :status, :started_at, :completed_at, :notes,
      custom_attributes: {}
    )
  end

  def deployment_json(deployment, full: false)
    data = {
      id: deployment.id,
      title: deployment.title,
      status: deployment.status,
      started_at: deployment.started_at,
      completed_at: deployment.completed_at,
      notes: deployment.notes,
      custom_attributes: deployment.custom_attributes,
      created_at: deployment.created_at,
      updated_at: deployment.updated_at,
      company: deployment.company&.as_json(only: [:id, :name, :description]),
      contact: deployment.contact&.as_json(only: [:id, :name, :email, :phone_number]),
      assignee: deployment.assignee&.as_json(only: [:id, :name, :email, :available_name, :thumbnail]),
      systems_count: deployment.deployment_systems.size,
      activities_count: deployment.deployment_activities.size,
      trainings_count: deployment.deployment_trainings.size,
      installations_count: deployment.deployment_installations.size,
      hardwares_count: deployment.deployment_hardwares.size,
      networks_count: deployment.deployment_networks.size
    }

    if full
      data[:activities] = deployment.deployment_activities
                                    .includes(:user)
                                    .ordered
                                    .map { |a| activity_json(a) }
      data[:systems] = deployment.deployment_systems
                                  .includes(:installed_by)
                                  .ordered
                                  .as_json(include: { installed_by: { only: [:id, :name] } })
      data[:trainings] = deployment.deployment_trainings
                                    .includes(:contact, :trained_by)
                                    .ordered
                                    .as_json(include: {
                                               contact: { only: [:id, :name, :phone_number] },
                                               trained_by: { only: [:id, :name] }
                                             })
      data[:installations] = deployment.deployment_installations
                                       .includes(:installed_by)
                                       .ordered
                                       .as_json(include: { installed_by: { only: [:id, :name] } })
      data[:hardwares] = deployment.deployment_hardwares
                                   .includes(:installed_by)
                                   .ordered
                                   .as_json(include: { installed_by: { only: [:id, :name] } })
      data[:networks] = deployment.deployment_networks
                                  .includes(:installed_by)
                                  .ordered
                                  .as_json(include: { installed_by: { only: [:id, :name] } })
    end

    data
  end

  def activity_json(activity)
    {
      id: activity.id,
      activity_type: activity.activity_type,
      description: activity.description,
      occurred_at: activity.occurred_at,
      duration_minutes: activity.duration_minutes,
      metadata: activity.metadata,
      created_at: activity.created_at,
      user: activity.user.as_json(only: [:id, :name, :available_name, :thumbnail])
    }
  end
end

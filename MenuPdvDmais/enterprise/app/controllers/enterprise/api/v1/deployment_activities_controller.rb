# frozen_string_literal: true

class Enterprise::Api::V1::DeploymentActivitiesController < Api::BaseController
  include EnterpriseHelper

  before_action :set_account
  before_action :set_deployment
  before_action :set_activity, only: [:update, :destroy]

  def index
    @activities = @deployment.deployment_activities
                             .includes(:user)
                             .ordered

    render json: @activities.map { |a| activity_json(a) }
  end

  def create
    @activity = @deployment.deployment_activities.build(activity_params)
    @activity.user = current_user

    if @activity.save
      render json: activity_json(@activity), status: :created
    else
      render json: @activity.errors, status: :unprocessable_entity
    end
  end

  def update
    if @activity.update(activity_params)
      render json: activity_json(@activity)
    else
      render json: @activity.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @activity.destroy
    head :no_content
  end

  private

  def set_account
    @account = Account.find(params[:account_id])
  end

  def set_deployment
    @deployment = @account.client_deployments.find(params[:client_deployment_id])
  end

  def set_activity
    @activity = @deployment.deployment_activities.find(params[:id])
  end

  def activity_params
    params.require(:deployment_activity).permit(
      :activity_type, :description, :occurred_at, :duration_minutes,
      metadata: {}
    )
  end

  def activity_json(activity)
    {
      id: activity.id,
      client_deployment_id: activity.client_deployment_id,
      activity_type: activity.activity_type,
      description: activity.description,
      occurred_at: activity.occurred_at,
      duration_minutes: activity.duration_minutes,
      metadata: activity.metadata,
      created_at: activity.created_at,
      updated_at: activity.updated_at,
      user: activity.user.as_json(only: [:id, :name, :available_name, :thumbnail])
    }
  end
end

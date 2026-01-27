class Api::V1::KanbanColumnsController < ApplicationController
  include EnterpriseHelper

  before_action :set_account
  before_action :set_kanban_column, only: [:show, :update, :destroy]

  def index
    @kanban_columns = @account.kanban_columns.ordered
    render json: @kanban_columns
  end

  def show
    render json: @kanban_column
  end

  def create
    @kanban_column = @account.kanban_columns.build(kanban_column_params)

    if @kanban_column.save
      render json: @kanban_column, status: :created
    else
      render json: @kanban_column.errors, status: :unprocessable_entity
    end
  end

  def update
    if @kanban_column.update(kanban_column_params)
      render json: @kanban_column
    else
      render json: @kanban_column.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @kanban_column.destroy
    head :no_content
  end

  private

  def set_account
    @account = current_account
  end

  def set_kanban_column
    @kanban_column = @account.kanban_columns.find(params[:id])
  end

  def kanban_column_params
    params.require(:kanban_column).permit(:name, :color, :position)
  end
end

# frozen_string_literal: true

class Enterprise::Api::V1::TelegramEventsController < ActionController::API
  skip_before_action :authenticate_user!, raise: false
  skip_before_action :set_account_user, raise: false
  skip_before_action :verify_authenticity_token, raise: false

  def process_payload
    @account = Account.find(params[:account_id])
    # Processa via Service para manter o controller enxuto
    Enterprise::TelegramBotService.new(@account, params.to_unsafe_hash).perform
    head :ok
  rescue StandardError => e
    Rails.logger.error "TelegramBot Error: #{e.message} at #{e.backtrace.first}"
    head :ok
  end
end

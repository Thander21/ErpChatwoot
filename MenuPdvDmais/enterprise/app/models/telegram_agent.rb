# frozen_string_literal: true

class TelegramAgent < ApplicationRecord
  belongs_to :user
  belongs_to :account

  validates :telegram_user_id, presence: true, uniqueness: true
  validates :user_id, presence: true
  validates :account_id, presence: true
end

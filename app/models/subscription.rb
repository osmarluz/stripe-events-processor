# frozen_string_literal: true

class Subscription < ApplicationRecord
  include AASM

  validates :external_id, :source, :data, presence: true
  validates :external_id, uniqueness: { scope: :source }

  enum source: { stripe: 'stripe' }

  aasm column: :state, timestamps: true do
    state :pending, initial: true
    state :paid
    state :canceled

    event :pay do
      transitions from: :pending, to: :paid
    end

    event :cancel do
      transitions from: :paid, to: :canceled
    end
  end
end

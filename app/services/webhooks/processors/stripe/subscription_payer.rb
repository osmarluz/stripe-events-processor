# frozen_string_literal: true

module Webhooks
  module Processors
    class Stripe
      class SubscriptionPayer
        include Dry::Monads[:result]

        def initialize(event:)
          @event = event
        end

        def call
          unless subscription&.pay!
            Rails.logger.info(
              class: 'Webhooks::Processors::Stripe::SubscriptionCanceler',
              message: "Attempt to pay subscription #{subscription_id} that's not unpaid was made",
              subscription_id:
            )
          end

          Success()
        end

        private

        attr_reader :event

        def subscription
          @subscription ||= Subscription.find_by(
            external_id: subscription_id,
            source: :stripe,
            state: :unpaid
          )
        end

        def subscription_id
          @subscription_id ||= event.data.object.subscription
        end
      end
    end
  end
end

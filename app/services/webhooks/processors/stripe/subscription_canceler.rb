# frozen_string_literal: true

module Webhooks
  module Processors
    class Stripe
      class SubscriptionCanceler
        include Dry::Monads[:result]

        def initialize(event:)
          @event = event
        end

        def call
          unless subscription&.cancel!
            Rails.logger.info(
              class: 'Webhooks::Processors::Stripe::SubscriptionCanceler',
              message: "Attempt to cancel subscription #{subscription_id} that's not paid was made",
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
            state: :paid
          )
        end

        def subscription_id
          @subscription_id ||= event.data.object.id
        end
      end
    end
  end
end

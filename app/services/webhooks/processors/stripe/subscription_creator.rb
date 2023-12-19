# frozen_string_literal: true

module Webhooks
  module Processors
    class Stripe
      class SubscriptionCreator
        include Dry::Monads[:try]

        def initialize(event:)
          @event = event
        end

        def call
          if result.failure?
            exception = result.failure

            Rails.logger.error(
              class: 'Webhooks::Processors::Stripe::SubscriptionCreator',
              exception: exception.class.name,
              message: exception.message,
              backtrace: exception.backtrace
            )
          end

          result
        end

        private

        attr_reader :event

        def result
          @result ||= Try do
            Subscription.create!(
              external_id: event.data.object.id,
              source: :stripe,
              data: event.data.object.to_h
            )
          end.to_result
        end
      end
    end
  end
end

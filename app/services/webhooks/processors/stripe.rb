# frozen_string_literal: true

module Webhooks
  module Processors
    class Stripe
      include Dry::Monads[:result]

      PROCESSORS = {
        'customer.subscription.created' => Stripe::SubscriptionCreator,
        'customer.subscription.deleted' => Stripe::SubscriptionCanceler,
        'invoice.paid' => Stripe::SubscriptionPayer
      }.freeze

      def initialize(request:)
        @request = request
      end

      def call
        processor = PROCESSORS[event.type]

        if processor.blank?
          Rails.logger.error(
            class: self.class.name,
            message: "No processor found for event type #{event.type}",
            event_type: event.type
          )

          return Failure()
        end

        processor.new(event:).call
      end

      private

      attr_reader :request

      def event
        @event ||= ::Stripe::Webhook.construct_event(
          request.body.read,
          request.env['HTTP_STRIPE_SIGNATURE'],
          Rails.application.credentials.stripe.webhook_secret
        )
      end
    end
  end
end

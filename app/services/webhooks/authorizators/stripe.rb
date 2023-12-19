# frozen_string_literal: true

module Webhooks
  module Authorizators
    class Stripe
      include Dry::Monads[:result, :try]

      def initialize(request:)
        @request = request
      end

      def call
        if result.failure?
          exception = result.failure

          Rails.logger.error(
            class: self.class.name,
            exception: exception.class.name,
            message: exception.message,
            backtrace: exception.backtrace
          )
        end

        result
      end

      private

      attr_reader :request

      def result
        @result ||= Try[::JSON::ParserError, ::Stripe::SignatureVerificationError] do
          ::Stripe::Webhook.construct_event(
            request.body.read,
            request.env['HTTP_STRIPE_SIGNATURE'],
            Rails.application.credentials.stripe.webhook_secret
          )
        end.to_result
      end
    end
  end
end

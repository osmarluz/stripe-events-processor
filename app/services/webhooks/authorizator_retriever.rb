# frozen_string_literal: true

module Webhooks
  class AuthorizatorRetriever
    include Dry::Monads[:result]

    AUTHORIZATORS = {
      stripe: Authorizators::Stripe
    }.with_indifferent_access.freeze

    def initialize(integration:)
      @integration = integration
    end

    def call
      authorizator = AUTHORIZATORS[integration]

      return Failure() if authorizator.blank?

      Success(authorizator)
    end

    private

    attr_reader :integration
  end
end

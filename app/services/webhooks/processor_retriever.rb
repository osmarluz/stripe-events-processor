# frozen_string_literal: true

module Webhooks
  class ProcessorRetriever
    include Dry::Monads[:result]

    PROCESSORS = {
      stripe: Processors::Stripe
    }.with_indifferent_access.freeze

    def initialize(integration:)
      @integration = integration
    end

    def call
      processor = PROCESSORS[integration]

      return Failure() if processor.blank?

      Success(processor)
    end

    private

    attr_reader :integration
  end
end

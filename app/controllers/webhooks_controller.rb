# frozen_string_literal: true

class WebhooksController < ApplicationController
  include Dry::Monads[:result]

  before_action { authorize(params[:integration], request) }

  def receive
    case Webhooks::ProcessorRetriever.new(integration: params[:integration]).call
    in Success(_ => processor)
      case processor.new(request:).call
      in Success
        head :ok
      in Failure
        head :unprocessable_entity
      end
    in Failure
      head :not_found
    end
  end

  private

  def authorize(integration, request)
    case Webhooks::AuthorizatorRetriever.new(integration:).call
    in Success(_ => authorizator)
      case authorizator.new(request:).call
      in Success
      # Proceed
      in Failure
        head :unauthorized and return
      end
    in Failure
      head :not_found and return
    end
  end
end

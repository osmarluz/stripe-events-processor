# frozen_string_literal: true

Rails.application.routes.draw do
  post '/:integration' => 'webhooks#receive', as: 'webhooks_receive'
end

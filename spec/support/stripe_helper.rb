# frozen_string_literal: true

module StripeHelper
  def generate_webhook_signature(payload)
    secret = Rails.application.credentials.stripe.webhook_secret
    time = Time.zone.now
    signature = Stripe::Webhook::Signature.compute_signature(time, payload, secret)
    Stripe::Webhook::Signature.generate_header(
      time,
      signature,
      scheme: Stripe::Webhook::Signature::EXPECTED_SCHEME
    )
  end
end

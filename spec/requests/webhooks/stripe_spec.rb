# frozen_string_literal: true

require '/app/spec/support/stripe_helper'

describe 'POST /receive/stripe' do
  include StripeHelper

  context 'when the request headers contain no signature' do
    it 'returns 401 status' do
      post webhooks_receive_path('stripe'), params: {}, headers: {}, as: :json

      expect(response).to have_http_status(:unauthorized)
    end
  end

  context 'when the request headers contain an invalid signature' do
    it 'returns 401 status' do
      post webhooks_receive_path('stripe'),
           params: {},
           headers: { 'Stripe-Signature' => 'invalid' },
           as: :json

      expect(response).to have_http_status(:unauthorized)
    end
  end

  context 'when the event type is not supported' do
    it 'returns 422 status' do
      payload = { type: 'whatever', foo: :bar }

      post webhooks_receive_path('stripe'),
           params: payload,
           headers: { 'Stripe-Signature' => generate_webhook_signature(payload.to_json) },
           as: :json

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  context 'when the event type is customer.subscription.created' do
    let(:payload) do
      {
        type: 'customer.subscription.created',
        data: {
          object: {
            id: 'abcd'
          }
        }
      }
    end
    let(:signature) { generate_webhook_signature(payload.to_json) }

    it 'returns 200 status' do
      post webhooks_receive_path('stripe'),
           params: payload,
           headers: { 'Stripe-Signature' => signature },
           as: :json

      expect(response).to have_http_status(:ok)
    end

    it 'creates the subscription' do
      post webhooks_receive_path('stripe'),
           params: payload,
           headers: { 'Stripe-Signature' => signature },
           as: :json

      expect(Subscription.sole).to have_attributes(
        external_id: 'abcd',
        state: 'unpaid',
        source: 'stripe',
        data: { 'id' => 'abcd' }
      )
    end
  end

  context 'when the event type is customer.subscription.deleted' do
    let(:payload) do
      {
        type: 'customer.subscription.deleted',
        data: {
          object: {
            id: 'abcd'
          }
        }
      }
    end
    let(:signature) { generate_webhook_signature(payload.to_json) }

    context 'when the subscription is paid' do
      let!(:subscription) do
        create(:subscription, :paid, external_id: 'abcd')
      end

      it 'returns 200 status' do
        post webhooks_receive_path('stripe'),
             params: payload,
             headers: { 'Stripe-Signature' => signature },
             as: :json

        expect(response).to have_http_status(:ok)
      end

      it 'cancels the subscription' do
        post webhooks_receive_path('stripe'),
             params: payload,
             headers: { 'Stripe-Signature' => signature },
             as: :json

        expect(subscription.reload).to be_canceled
      end
    end

    context 'when the subscription is not paid' do
      let!(:subscription) do
        create(:subscription, external_id: 'abcd')
      end

      it 'returns 200 status' do
        post webhooks_receive_path('stripe'),
             params: payload,
             headers: { 'Stripe-Signature' => generate_webhook_signature(payload.to_json) },
             as: :json

        expect(response).to have_http_status(:ok)
      end

      it 'does not cancel the subscription' do
        post webhooks_receive_path('stripe'),
             params: payload,
             headers: { 'Stripe-Signature' => generate_webhook_signature(payload.to_json) },
             as: :json

        expect(subscription.reload).to be_unpaid
      end
    end
  end

  context 'when the event type is invoice.paid' do
    let(:payload) do
      {
        type: 'invoice.paid',
        data: {
          object: {
            subscription: 'abcd'
          }
        }
      }
    end
    let(:signature) { generate_webhook_signature(payload.to_json) }

    context 'when the subscription is unpaid' do
      let!(:subscription) do
        create(:subscription, external_id: 'abcd')
      end

      it 'returns 200 status' do
        post webhooks_receive_path('stripe'),
             params: payload,
             headers: { 'Stripe-Signature' => signature },
             as: :json

        expect(response).to have_http_status(:ok)
      end

      it 'pays the subscription' do
        post webhooks_receive_path('stripe'),
             params: payload,
             headers: { 'Stripe-Signature' => signature },
             as: :json

        expect(subscription.reload).to be_paid
      end
    end

    context 'when the subscription is not unpaid' do
      let!(:subscription) do
        create(:subscription, :canceled, external_id: 'abcd')
      end

      it 'returns 200 status' do
        post webhooks_receive_path('stripe'),
             params: payload,
             headers: { 'Stripe-Signature' => signature },
             as: :json

        expect(response).to have_http_status(:ok)
      end

      it 'does not pay the subscription' do
        post webhooks_receive_path('stripe'),
             params: payload,
             headers: { 'Stripe-Signature' => signature },
             as: :json

        expect(subscription.reload).to be_canceled
      end
    end
  end
end

# frozen_string_literal: true

describe Webhooks::Processors::Stripe::SubscriptionCanceler do
  let(:event) { double(Stripe::Event, data: double(object: double(id: 'abc'))) }

  it 'returns a success result' do
    expect(described_class.new(event:).call).to be_success
  end

  context 'when the subscription is found' do
    let!(:subscription) { create(:subscription, :paid, external_id: 'abc') }

    it 'cancels the subscription' do
      described_class.new(event:).call

      expect(subscription.reload).to be_canceled
    end
  end

  context 'when the subscription is not found' do
    it 'logs an info message' do
      create(:subscription, external_id: 'abc')

      allow(Rails.logger).to receive(:info)

      described_class.new(event:).call

      expect(Rails.logger).to have_received(:info).with(
        class: 'Webhooks::Processors::Stripe::SubscriptionCanceler',
        message: "Attempt to cancel subscription abc that's not paid was made",
        subscription_id: 'abc'
      )
    end
  end
end

# frozen_string_literal: true

describe Webhooks::Processors::Stripe::SubscriptionPayer do
  let(:event) { double(Stripe::Event, data: double(object: double(subscription: 'abc'))) }

  it 'returns a success result' do
    expect(described_class.new(event:).call).to be_success
  end

  context 'when the subscription is found' do
    let!(:subscription) { create(:subscription, external_id: 'abc') }

    it 'pays the subscription' do
      described_class.new(event:).call

      expect(subscription.reload).to be_paid
    end
  end

  context 'when the subscription is not found' do
    it 'logs an info message' do
      create(:subscription, :paid, external_id: 'abc')

      allow(Rails.logger).to receive(:info)

      described_class.new(event:).call

      expect(Rails.logger).to have_received(:info).with(
        class: 'Webhooks::Processors::Stripe::SubscriptionCanceler',
        message: "Attempt to pay subscription abc that's not unpaid was made",
        subscription_id: 'abc'
      )
    end
  end
end

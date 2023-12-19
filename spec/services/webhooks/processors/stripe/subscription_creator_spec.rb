# frozen_string_literal: true

describe Webhooks::Processors::Stripe::SubscriptionCreator do
  let(:event) { double(Stripe::Event, data: double(object: double(id: 'abc', to_h: { foo: :bar }))) }

  context 'when the creation is successful' do
    it 'returns a success result' do
      expect(described_class.new(event:).call).to be_success
    end

    it 'persists the object' do
      described_class.new(event:).call

      expect(Subscription.sole).to have_attributes(
        external_id: 'abc',
        source: 'stripe',
        data: { 'foo' => 'bar' }
      )
    end
  end

  context 'when the creation is not successful' do
    before do
      allow(Subscription).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new)
    end

    it 'returns a failure result' do
      expect(described_class.new(event:).call).to be_failure
    end

    it 'logs an info message' do
      allow(Rails.logger).to receive(:error)

      described_class.new(event:).call

      expect(Rails.logger).to have_received(:error).with(
        class: 'Webhooks::Processors::Stripe::SubscriptionCreator',
        exception: 'ActiveRecord::RecordInvalid',
        message: 'Record invalid',
        backtrace: anything
      )
    end
  end
end

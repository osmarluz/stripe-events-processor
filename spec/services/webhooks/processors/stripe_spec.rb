# frozen_string_literal: true

describe Webhooks::Processors::Stripe do
  let(:request) { instance_double(ActionDispatch::Request) }

  before do
    allow(request).to receive_messages(body: double(read: 'body'), env: { 'HTTP_STRIPE_SIGNATURE' => 'signature' })
    allow(Rails.application.credentials.stripe).to receive(:webhook_secret).and_return('secret')
    allow(Stripe::Webhook).to receive(:construct_event).and_return(event)
  end

  context 'when integration exists' do
    context 'when event type is customer.subscription.created' do
      let(:event) { double(Stripe::Event, type: 'customer.subscription.created') }
      let(:processor) { instance_double(Webhooks::Processors::Stripe::SubscriptionCreator, call: anything) }

      it 'calls the processor' do
        allow(Webhooks::Processors::Stripe::SubscriptionCreator).to receive(:new).with(event:).and_return(processor)

        described_class.new(request:).call

        expect(processor).to have_received(:call)
      end
    end

    context 'when event type is customer.subscription.deleted' do
      let(:event) { double(Stripe::Event, type: 'customer.subscription.deleted') }
      let(:processor) { instance_double(Webhooks::Processors::Stripe::SubscriptionCanceler, call: anything) }

      it 'calls the processor' do
        allow(Webhooks::Processors::Stripe::SubscriptionCanceler).to receive(:new).with(event:).and_return(processor)

        described_class.new(request:).call

        expect(processor).to have_received(:call)
      end
    end

    context 'when event type is invoice.paid' do
      let(:event) { double(Stripe::Event, type: 'invoice.paid') }
      let(:processor) { instance_double(Webhooks::Processors::Stripe::SubscriptionPayer, call: anything) }

      it 'calls the processor' do
        allow(Webhooks::Processors::Stripe::SubscriptionPayer).to receive(:new).with(event:).and_return(processor)

        described_class.new(request:).call

        expect(processor).to have_received(:call)
      end
    end
  end

  context 'when integration does not exist' do
    let(:event) { double(Stripe::Event, type: 'whatever') }

    it 'returns a failure result' do
      expect(described_class.new(request:).call).to be_failure
    end

    it 'logs the error' do
      allow(Rails.logger).to receive(:error)

      described_class.new(request:).call

      expect(Rails.logger).to have_received(:error).with(
        class: 'Webhooks::Processors::Stripe',
        message: 'No processor found for event type whatever',
        event_type: 'whatever'
      )
    end
  end
end

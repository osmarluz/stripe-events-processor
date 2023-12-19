# frozen_string_literal: true

describe Webhooks::Authorizators::Stripe do
  let(:request) { instance_double(ActionDispatch::Request) }

  before do
    allow(request).to receive_messages(body: double(read: 'body'), env: { 'HTTP_STRIPE_SIGNATURE' => 'signature' })
    allow(Rails.application.credentials.stripe).to receive(:webhook_secret).and_return('secret')
  end

  context 'when the event is constructed successfully' do
    let(:event) { instance_double(Stripe::Event) }

    before do
      allow(Stripe::Webhook).to receive(:construct_event).and_return(event)
    end

    it 'returns a success result' do
      expect(described_class.new(request:).call).to be_success
    end
  end

  context 'when there is an error constructing the event' do
    let(:exception) { Stripe::SignatureVerificationError.new('message', '') }

    before do
      allow(Stripe::Webhook).to receive(:construct_event).and_raise(exception)
      allow(Rails.logger).to receive(:error)
    end

    it 'returns a failure result' do
      expect(described_class.new(request:).call).to be_failure
    end

    it 'logs the error' do
      described_class.new(request:).call

      expect(Rails.logger).to have_received(:error).with(
        class: 'Webhooks::Authorizators::Stripe',
        exception: 'Stripe::SignatureVerificationError',
        message: 'message',
        backtrace: anything
      )
    end
  end
end

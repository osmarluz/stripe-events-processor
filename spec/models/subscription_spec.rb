# frozen_string_literal: true

describe Subscription do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:external_id) }
    it { is_expected.to validate_presence_of(:source) }
    it { is_expected.to validate_presence_of(:data) }

    it 'validates uniqueness of external_id scoped to source' do
      subscription = create(:subscription)
      expect(subscription).to validate_uniqueness_of(:external_id).scoped_to(:source)
    end
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:source).with_values(stripe: 'stripe').backed_by_column_of_type(:string) }
  end

  describe 'state machine' do
    let(:subscription) { create(:subscription) }

    it 'starts in the pending state' do
      expect(subscription).to have_state(:pending)
    end

    it 'transitions from pending to paid when pay event is triggered' do
      expect(subscription).to transition_from(:pending).to(:paid).on_event(:pay)
    end

    it 'transitions from paid to canceled when cancel event is triggered' do
      expect(subscription).to transition_from(:paid).to(:canceled).on_event(:cancel)
    end
  end
end

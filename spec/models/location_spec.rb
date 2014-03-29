# == Schema Information
#
# Table name: locations
#
#  id                   :integer          not null, primary key
#  name                 :string(255)
#  created_at           :datetime
#  updated_at           :datetime
#  most_recent_activity :datetime
#  lat                  :string(255)
#  long                 :string(255)
#  description          :text
#

require 'spec_helper'

describe Location do
  subject(:location) { create(:location, name: '123 Maple Street') }

  it { should validate_presence_of :name }

  it { should have_many :notification_subscriptions }
  it { should have_many :feedback_inputs }

  it { should allow_mass_assignment_of :name }
  it { should allow_mass_assignment_of :lat }
  it { should allow_mass_assignment_of :long }
  it { should allow_mass_assignment_of :description }
  it { should allow_mass_assignment_of :most_recent_activity }

  its(:url_to) { should == '/locations/123-Maple-Street' }

  describe '.find_by_param' do
    let!(:location) { create(:location, name: '123 Maple Street') }

    context 'when the location exists' do
      it 'finds the location by id' do
        expect(Location.find_by_param(location.id.to_s)).to eq(location)
      end

      it 'finds the location by name with dashes' do
        expect(Location.find_by_param('123-Maple-Street')).to eq(location)
      end
    end

    context 'when the location does not exist' do
      it 'blows up when finding by id' do
        expect { Location.find_by_param('0') }.to raise_error
      end

      it 'blows up when finding by name' do
        expect { Location.find_by_param('Taco-Trucks') }.to raise_error
      end
    end
  end

  describe '.activity_since' do
    let!(:location) { create(:location, most_recent_activity: Time.now) }

    context 'when the most recent activity is before the time' do
      it 'does not return the location' do
        expect(Location.activity_since(Time.now + 1.day)).to be_empty
      end
    end

    context 'when the most recent activity is after the time' do
      it 'returns the location' do
        expect(Location.activity_since(1.day.ago)).to eq([location])
      end
    end
  end

  describe '#new_activity!' do
    let!(:location) { create(:location, name: '123 Maple Street') }

    it 'sets the most recent activity' do
      Timecop.freeze(DateTime.parse('December 23, 2013')) do
        expect {
          location.new_activity!
        }.to change { location.reload.most_recent_activity }.to(Time.now)
      end
    end
  end

  describe '#property_code' do
    it 'is the zero-padded version of the id' do
      expect(location.property_code).to eq(location.id.to_s.rjust(3, '0'))
    end
  end

  describe '#numerical_responses' do
    let(:question) { create(:question, :number) }

    subject(:location) { create(:location) }

    before { create(:feedback_input, location: location, question: question, numerical_response: 1) }

    its(:numerical_responses) { should have(1).numerical_response }
  end

  describe '#voice_messages' do
    subject(:location) { create(:location) }

    before { create(:feedback_input, :with_voice_file, location: location) }

    its(:voice_messages) { should have(1).voice_message }
  end
end

require 'rails_helper'
require 'data_validator'

RSpec.describe DataValidator do

  ###############
  # Class methods
  ###############

  describe '::classes' do
    subject { DataValidator.classes }

    it { should be_an(Array) }
    
    # include regular activerecord models
    it { should include(AccessToken) }
    it { should include(Industry) }
    it { should include(Interest) }
    it { should include(Location) }
    it { should include(Major) }
    it { should include(PostalCode) }
    it { should include(User) }
    
    # don't include abstract or table-less models
    it { should_not include(ApplicationRecord) }
  end
  
  ##################
  # Instance methods
  ##################
  
  describe '#invalids(model_class)' do
    let(:model_class) { Major }
    let(:model) { create :major }
    let(:data_validator) { DataValidator.new }
    
    # complicated way to get around validation when needed
    before { model_class.where(id: model.id).update_all(name: name) }
    
    subject { data_validator.invalids(model_class) }

    describe 'when only valid records exist' do
      let(:name) { 'Test' }

      it { should be_an(Array) }
      it { should be_empty }
    end
    
    describe 'when an invalid record exists' do
      let(:name) { '' }
      
      it { should be_an(Array) }
      it { should_not be_empty }
      
      it { should include(model.id) }
    end
  end
  
  describe '#report' do
    let(:model_class) { Major }
    let(:model) { create :major }
    let(:data_validator) { DataValidator.new }
    
    # complicated way to get around validation when needed
    before { model_class.where(id: model.id).update_all(name: name) }
    
    subject { data_validator.report }
    
    describe 'when only valid records exist' do
      let(:name) { 'Test' }
      
      it { should be_a(Hash) }
      
      it { expect(subject[:valid]).to be_truthy }
      
      [:access_token, :industry, :interest, :location, :postal_code, :user].each do |key|
        it { expect(subject[:models].keys).to include(key) }
        it { expect(subject[:models][key][:invalid_ids]).to be_an(Array) }
        it { expect(subject[:models][key][:invalid_ids]).to be_empty }
        it { expect(subject[:models][key][:total]).to eq(0) }
        it { expect(subject[:models][key][:valid]).to eq(0) }
        it { expect(subject[:models][key][:invalid]).to eq(0) }
      end
      
      it { expect(subject[:models].keys).to include(:major) }
      it { expect(subject[:models][:major][:invalid_ids]).to be_an(Array) }
      it { expect(subject[:models][:major][:invalid_ids]).to be_empty }
      it { expect(subject[:models][:major][:total]).to eq(1) }
      it { expect(subject[:models][:major][:valid]).to eq(1) }
      it { expect(subject[:models][:major][:invalid]).to eq(0) }
    end
    
    describe 'when an invalid record exists' do
      let(:name) { '' }
      
      it { should be_a(Hash) }
      
      it { expect(subject[:valid]).to be_falsey }
      
      [:access_token, :industry, :interest, :location, :postal_code, :user].each do |key|
        it { expect(subject[:models].keys).to include(key) }
        it { expect(subject[:models][key][:invalid_ids]).to be_an(Array) }
        it { expect(subject[:models][key][:invalid_ids]).to be_empty }
        it { expect(subject[:models][key][:total]).to eq(0) }
        it { expect(subject[:models][key][:valid]).to eq(0) }
        it { expect(subject[:models][key][:invalid]).to eq(0) }
      end
      
      it { expect(subject[:models].keys).to include(:major) }
      it { expect(subject[:models][:major][:invalid_ids]).to be_an(Array) }
      it { expect(subject[:models][:major][:invalid_ids]).to include(model.id) }
      it { expect(subject[:models][:major][:total]).to eq(1) }
      it { expect(subject[:models][:major][:valid]).to eq(0) }
      it { expect(subject[:models][:major][:invalid]).to eq(1) }
    end
  end
end

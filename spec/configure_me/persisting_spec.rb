require 'spec_helper'

describe ConfigureMe::Persisting do
  class Setting; end
  class PersistingConfig < ConfigureMe::Base
    setting :persistedsetting, :type => :string, :default => 'persisted'
    persist_me
  end

  class NonPersistingConfig < ConfigureMe::Base
    setting :nonpersistedsetting, :type => :string, :default => 'nonpersisted'
  end

  describe 'the class' do
    subject { PersistingConfig }
    it { should respond_to(:persistence_key) }
    it 'should generate a valid persistence key' do
      subject.persistence_key('persistedsetting').should eql('persisting_persistedsetting')
    end
  end

  describe 'an instance' do
    subject { PersistingConfig.instance }
    it { should respond_to(:write_persist) }
    it { should respond_to(:read_persist) }

    context 'when persisting is disabled' do
      subject { NonPersistingConfig.instance }
      describe 'read_persist' do

      end
    end
  end
end

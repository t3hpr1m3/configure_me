require 'spec_helper'

describe ConfigureMe::Naming do
  class NamingConfig < ConfigureMe::Base
  end

  before {
    @persistence_klass = mock('PersistenceKlass') do
      stubs(:model_name).returns('persistence')
    end
    ConfigureMe.stubs(:persistence_klass).returns(@persistence_klass)
  }
  subject { NamingConfig }
  context 'when persisting' do
    before { NamingConfig.stubs(:persisting?).returns(true) }
    its(:model_name) { should eql('persistence') }
  end

  context 'when not persisting' do
    before { NamingConfig.stubs(:persisting?).returns(false) }
    its(:model_name) { should_not eql('persistence') }
  end
end

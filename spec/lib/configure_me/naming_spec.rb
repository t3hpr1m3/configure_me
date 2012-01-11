require 'spec_helper'

describe ConfigureMe::Naming do
  class NamingTester
    include ConfigureMe::Naming
  end

  let(:persistence_klass) { stub(:model_name => 'persistence') }
  before {
    ConfigureMe.stubs(:persistence_klass).returns(persistence_klass)
  }
  subject { NamingTester }
  context 'when persisting' do
    before { NamingTester.stubs(:persisting?).returns(true) }
    its(:model_name) { should eql('persistence') }
  end

  context 'when not persisting' do
    before { NamingTester.stubs(:persisting?).returns(false) }
    its(:model_name) { should_not eql('persistence') }
  end
end

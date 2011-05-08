require 'spec_helper'

describe ConfigureMe::Naming do
  class NamingConfig
    include ConfigureMe::Naming
  end

  describe 'the class' do
    subject { NamingConfig }
    it { should respond_to(:config_name) }
    its(:config_name) { should eql('naming') }
  end
end

require 'spec_helper'

describe ConfigureMe::Nesting do
  class RootConfig < BaseTestConfig
    include ConfigureMe::Nesting
  end
  class NestedConfig < BaseTestConfig
    include ConfigureMe::Nesting
  end

  before {
    @root_config = RootConfig.new
    @nested_config = NestedConfig.new
    NestedConfig.stubs(:instance).returns(@nested_config)
    RootConfig.stubs(:instance).returns(@root_config)
    NestedConfig.send :nest_me, RootConfig
  }

  describe 'the class' do
    subject { NestedConfig }
    it { should respond_to(:nest_me) }

    it 'should properly nest' do
      @root_config.expects(:nest)
      NestedConfig.send :nest_me, RootConfig
    end
  end

  describe 'a nested class' do
    subject { @nested_config }
    its(:parent_config) { should eql(@root_config) }
    its(:children) { should be_empty }
    its(:all_configs) { should have(1).items }
    its(:nested_name) { should eql('root-nested') }
  end

  describe 'a parent class' do
    subject { @root_config }
    its(:parent_config) { should be_nil }
    its(:children) { should eql({'nested' => @nested_config}) }
    it { should respond_to(:nested) }
    its(:all_configs) { should have(2).items }
  end
end

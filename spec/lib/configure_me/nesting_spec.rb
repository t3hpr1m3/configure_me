require 'spec_helper'

describe ConfigureMe::Nesting do
  class RootConfig
    include ConfigureMe::Nesting
  end
  class NestedConfig
    include ConfigureMe::Nesting
  end

  subject { RootConfig }
  it { should respond_to(:nest_me) }

  context 'a nested class' do
    before {
      NestedConfig.stubs(:config_name).returns('nested')
      RootConfig.stubs(:config_name).returns('root')
      NestedConfig.nest_me(RootConfig)
    }
    subject { NestedConfig }
    its(:nested_classes) { should be_empty }

    context 'instance' do
      let(:root_config) { RootConfig.new }
      subject { root_config.nested }
      its(:parent_config) { should eql(root_config) }
      its(:children) { should be_empty }
      its(:all_configs) { should have(1).items }
    end
  end

  context 'a root class' do
    before {
      NestedConfig.stubs(:config_name).returns('nested')
      RootConfig.stubs(:config_name).returns('root')
      NestedConfig.nest_me(RootConfig)
    }
    subject { RootConfig }
    its(:nested_classes) { should have(1).items }

    context 'instance' do
      let(:root_config) { RootConfig.new }
      let(:nested_config) { root_config.nested }
      before { root_config.nested }
      subject { root_config }
      it { should respond_to(:nested) }
      its(:children) { should have(1).items }
      its(:children) { should eql(:nested => nested_config) }
      its(:all_configs) { should have(2).items }
      its(:parent_config) { should be_nil }
      its(:nested) { should eql(nested_config) }
    end
  end
end

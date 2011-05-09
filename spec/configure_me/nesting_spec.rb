require 'spec_helper'

describe ConfigureMe::Nesting, 'the class' do
  subject { ConfigureMe::Base }
  it { should respond_to(:nest_me) }
end

describe ConfigureMe::Nesting do
  before {
    @parent_class = define_test_class('ParentConfig', ConfigureMe::Base)
    @nested_class = define_test_class('NestedConfig', ConfigureMe::Base)
    @parent_config = @parent_class.instance
    @nested_config = @nested_class.instance
    @parent_class.stubs(:instance).returns(@parent_config)
    @nested_class.stubs(:instance).returns(@nested_config)
    @nested_class.send(:nest_me, @parent_class)
  }

  context 'a nested class' do
    subject { @nested_config }
    its(:children) { should be_empty }
    its(:all_configs) { should have(1).items }
    its(:parent_config) { should eql(@parent_config) }
  end

  context 'a parent class' do
    subject { @parent_config }
    its(:children) { should have(1).items }
    its(:children) { should eql(:nested => @nested_config) }
    its(:all_configs) { should have(2).items }
    its(:parent_config) { should be_nil }
    it { should respond_to(:nested) }
    its(:nested) { should eql(@nested_config) }
    its(:class) { should respond_to(:nested) }
  end
end

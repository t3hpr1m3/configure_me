require 'spec_helper'

describe ConfigureMe::Identity do
  before {
    @parent_class = define_test_class('ParentConfig', ConfigureMe::Base)
    @nested_class = define_test_class('NestedConfig', ConfigureMe::Base)
  }

  context 'a root class' do
    subject { @parent_class.instance }
    it { should respond_to(:config_key) }
    it { should respond_to(:config_name) }
    it { should respond_to(:storage_key) }
    its(:config_name) { should eql('parent') }
    its(:config_key) { should eql('parent') }
    it 'should generate a valid storage key' do
      subject.storage_key('foo').should eql('parent-foo')
    end
  end

  context 'a nested class' do
    before { @nested_class.send(:nest_me, @parent_class) }
    subject { @nested_class.instance }
    its(:config_name) { should eql('nested') }
    its(:config_key) { should eql('parent-nested') }
    it 'should generate a valid storage key' do
      subject.storage_key('foo').should eql('parent-nested-foo')
    end
  end
end

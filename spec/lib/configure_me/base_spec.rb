require 'spec_helper'

describe ConfigureMe do
  it { should respond_to(:init) }
  it { should respond_to(:persistence_klass) }
  it { should respond_to(:cache_object) }
  it 'should provide nil defaults for :init' do
    ConfigureMe.init
    ConfigureMe.persistence_klass.should be_nil
    ConfigureMe.cache_object.should be_nil
  end

  it 'should accept a hash of initialization arguments' do
    ConfigureMe.init(:persist_with => 'foo', :cache_with => 'bar')
    ConfigureMe.persistence_klass.should eql('foo')
    ConfigureMe.cache_object.should eql('bar')
  end
end

describe ConfigureMe::Base do

  class BaseTesterConfig < ConfigureMe::Base
    setting :setting1, :type => :integer, :default => 12
  end

  subject { BaseTesterConfig.new }
  its(:persisted?) { should be_true }

  describe 'to_key' do
    context 'without a parent config' do
      before {
        subject.stubs(:parent_config).returns(nil)
      }
      its(:to_key) { should eql(['base_tester']) }
    end
    context 'with a parent config' do
      let(:parent_config) {
        mock('ParentConfig') do
          stubs(:to_key).returns(['parent'])
        end
      }
      before {
        subject.stubs(:parent_config).returns(parent_config)
      }
      its(:to_key) { should eql(['parent', 'base_tester']) }
    end
  end

  describe 'to_param' do
    context 'with a root config' do
      its(:to_param) { should eql('base_tester') }
    end
    context 'with a nested config' do
      before { subject.stubs(:to_key).returns(['parent', 'base_tester']) }
      its(:to_param) { should eql('parent-base_tester') }
    end
  end

  describe 'storage_key' do
    specify { subject.storage_key('foo').should eql('base_tester-foo') }
  end

  describe 'ActiveModel compliance' do
    subject { define_test_class('TestConfig', ConfigureMe::Base).new }
    it_should_behave_like "ActiveModel"
  end

  describe 'find_by_id' do
    subject { ConfigureMe::Base }
    let(:configs) { [stub(:config_key => 'the-right-one', :new => 'object')] }
    it 'should return nil for an invalid id' do
      subject.stubs(:configs).returns([])
      subject.find_by_id('something').should be_nil
    end

    it 'should return a matching config' do
      subject.stubs(:configs).returns(configs)
      subject.find_by_id('the-right-one').should eql('object')
    end
  end
end

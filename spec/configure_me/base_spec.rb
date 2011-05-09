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
  it 'should enforce the singleton pattern' do
    lambda { ConfigureMe::Base.new }.should raise_error(NoMethodError)
  end

  class BaseConfig < ConfigureMe::Base
    setting :setting1, :type => :integer, :default => 12
  end

  subject { BaseConfig.instance }
  its(:persisted?) { should be_true }
  its(:class) { should respond_to(:setting1) }

  describe 'ActiveModel compliance' do
    before { @config = define_test_class('TestConfig', ConfigureMe::Base).instance }
    subject { @config }
    it_should_behave_like "ActiveModel"
  end

  describe 'find_by_id' do
    subject { ConfigureMe::Base }
    before {
      @mock_config = mock('Config') do
        stubs(:config_key).returns('the-right-one')
        stubs(:instance).returns('instance')
      end
      @configs = [@mock_config]
    }
    it 'should return nil for an invalid id' do
      subject.stubs(:configs).returns([])
      subject.find_by_id('something').should be_nil
    end

    it 'should return a matching config' do
      subject.stubs(:configs).returns(@configs)
      subject.find_by_id('the-right-one').should eql('instance')
    end
  end
end

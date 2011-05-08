require 'spec_helper'

describe ConfigureMe do
  class Setting; end
  class Setting2; end
  it { should respond_to(:persist_with) }
  it { should respond_to(:persistence_klass) }
  it 'should default to ::Setting for the persistence_klass' do
    ConfigureMe.persist_with(nil)
    ConfigureMe.persistence_klass.should eql(::Setting)
  end
  it 'should update @persistence_klass when persist_with is called' do
    ConfigureMe.persist_with(Setting2)
    ConfigureMe.persistence_klass.should eql(Setting2)
  end
end

describe ConfigureMe::Base do

  class TestConfig < ConfigureMe::Base
    setting :setting1, :type => :integer, :default => 12
  end

  class ParentConfig < ConfigureMe::Base
  end

  describe 'ActiveModel compliance' do
    before { @config = TestConfig.send :new }
    subject { @config }
    it_should_behave_like "ActiveModel"
  end

  context 'an instance' do
    subject { TestConfig.instance }
    its(:to_key) { should eql(['test']) }
    its(:to_param) { should eql('test') }
    it 'should respond to known settings' do
      TestConfig.setting1.should eql(12)
    end

    it 'should fire method_missing for unknown settings' do
      lambda { TestConfig.setting2 }.should raise_error(NoMethodError)
    end
  end

  describe 'find_by_id' do
    subject { ConfigureMe::Base }
    before {
      @mock_config = mock('Config') do
        stubs(:nested_name).returns('the-right-one')
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

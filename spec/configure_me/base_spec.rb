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

  context 'an instance' do
    it 'should respond to known settings' do
      TestConfig.setting1.should eql(12)
    end

    it 'should fire method_missing for unknown settings' do
      lambda { TestConfig.setting2 }.should raise_error(NoMethodError)
    end
  end

  describe 'load' do
    it 'should raise an error with anything other than a hash' do
      lambda { ConfigureMe::Base.load('notahash') }.should raise_error(ArgumentError)
    end
    context 'with :app => {:setting1 => \'foo\', :setting2 => 845}' do
      describe 'the instance' do
        subject do
          ConfigureMe::Base.load(:app => {:setting1 => 'foo', :setting2 => 845})
        end
        its(:config_name) { should eql('app') }

        it { should respond_to(:setting1) }
        it { should respond_to(:setting2) }
        it { should_not respond_to(:setting3) }
        its(:setting1) { should eql('foo') }
        its(:setting2) { should eql(845) }
        its(:parent) { should be_nil }
      end
    end

    context 'with :group1 => {:setting1 => 6, :setting2 => \'foo\'}, :group2 => {:setting3 => 8, :setting4 => \'bar\'}' do
      describe 'the instance' do
        before(:all) do
          @config = ConfigureMe::Base.load(
            :group1 => {
              :setting1 => 6,
              :setting2 => 'foo'
            },
            :group2 => {
              :setting3 => 8,
              :setting4 => 'bar'
            }
          )
        end

        subject { @config }
        its(:config_name) { should eql('root') }
        it { should respond_to(:group1) }
        it { should respond_to(:group2) }
        it { should_not respond_to(:group3) }

        describe 'group1' do
          subject { @config.group1 }
          it { should_not be_nil }
          it { should respond_to(:setting1) }
          it { should respond_to(:setting2) }
          it { should_not respond_to(:setting3) }
          its(:setting1) { should eql(6) }
          its(:setting2) { should eql('foo') }
          its(:parent) { should eql(@config.instance) }
        end

        describe 'group2' do
          subject { @config.group2 }
          it { should_not be_nil }
          it { should respond_to(:setting3) }
          it { should respond_to(:setting4) }
          it { should_not respond_to(:setting1) }
          its(:setting3) { should eql(8) }
          its(:setting4) { should eql('bar') }
          its(:parent) { should eql(@config.instance) }
        end
      end
    end
  end
end

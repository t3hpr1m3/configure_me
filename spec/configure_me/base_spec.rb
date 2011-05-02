require 'spec_helper'

describe ConfigureMe::Base do
  class TestConfig < ConfigureMe::Base
    setting :setting1, :integer, :default => 12
  end

  class ParentConfig < ConfigureMe::Base
  end

  it 'should respond to known settings' do
    TestConfig.setting1.should eql(12)
  end

  it 'should fire method_missing for unknown settings' do
    lambda { TestConfig.setting2 }.should raise_error(NoMethodError)
  end

  describe 'load' do
    it 'should raise an error with anything other than a hash' do
      lambda { ConfigureMe::Base.load('notahash') }.should raise_error(ArgumentError)
    end
    context 'with a hash' do
      context 'with a single layer' do
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

      context 'with nested layers' do
        subject do
          ConfigureMe::Base.load(
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

        its(:config_name) { should eql('root') }

        it { should respond_to(:group1) }
        its(:group1) { should_not be_nil }
        its(:group1) { should respond_to(:setting1) }
        its(:group1) { should respond_to(:setting2) }
        its(:group1) { should_not respond_to(:setting3) }
        its('group1.setting1') { should eql(6) }
        its('group1.setting2') { should eql('foo') }
        its('group1.parent') { should eql(subject) }

        it { should respond_to(:group2) }
        its(:group2) { should_not be_nil }
        its(:group2) { should respond_to(:setting3) }
        its(:group2) { should respond_to(:setting4) }
        its(:group2) { should_not respond_to(:setting1) }
        its('group2.setting3') { should eql(8) }
        its('group2.setting4') { should eql('bar') }
        its('group2.parent') { should eql(subject) }

        it { should_not respond_to(:group3) }
      end
    end
  end
end

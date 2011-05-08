require 'spec_helper'

describe ConfigureMe::Loading do
  class LoadingTester
    extend ConfigureMe::Loading
  end
  describe 'load' do
    context 'with a string argument' do
      it 'should raise an error for a non-existent file' do
        lambda { LoadingTester.load('foo') }.should raise_error(ArgumentError)
      end
      it 'should load for an existent file' do
        File.stubs(:exists?).returns(true)
        File.stubs(:open).returns({:foo => 'bar'}.to_yaml)
        LoadingTester.expects(:from_hash)
        LoadingTester.load('avalidfile')
      end
    end
    it 'should raise an error with an unsupported argument' do
      lambda { LoadingTester.load(123) }.should raise_error(ArgumentError)
    end
    it 'should raise an error' do
    end
    context 'with :app => {:setting1 => \'foo\', :setting2 => 845}' do
      describe 'the instance' do
        before { @config = LoadingTester.load(:app => {:setting1 => 'foo', :setting2 => 845}) }
        subject { @config }
        its(:config_name) { should eql('app') }

        it { should respond_to(:setting1) }
        it { should respond_to(:setting2) }
        it { should_not respond_to(:setting3) }
        its(:setting1) { should eql('foo') }
        its(:setting2) { should eql(845) }
        its(:parent_config) { should be_nil }
      end
    end

    context 'with :group1 => {:setting1 => 6, :setting2 => \'foo\'}, :group2 => {:setting3 => 8, :setting4 => \'bar\'}' do
      describe 'the instance' do
        before {
          @config = LoadingTester.load(
            :group1 => {
              :setting1 => 6,
              :setting2 => 'foo'
            },
            :group2 => {
              :setting3 => 8,
              :setting4 => 'bar'
            }
          )
        }

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
          its(:parent_config) { should eql(@config.instance) }
        end

        describe 'group2' do
          subject { @config.group2 }
          it { should_not be_nil }
          it { should respond_to(:setting3) }
          it { should respond_to(:setting4) }
          it { should_not respond_to(:setting1) }
          its(:setting3) { should eql(8) }
          its(:setting4) { should eql('bar') }
          its(:parent_config) { should eql(@config.instance) }
        end
      end
    end
  end
end

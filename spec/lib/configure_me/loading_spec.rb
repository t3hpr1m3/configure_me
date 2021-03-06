require 'spec_helper'

describe ConfigureMe::Loading do
  class ConfigLoader
    extend ConfigureMe::Loading
  end

  context 'a filename' do
    subject { ConfigLoader }
    it 'should raise an error for a non-existent file' do
      lambda { subject.load('foo') }.should raise_error(ArgumentError)
    end

    it 'should load an existing file' do
      File.stubs(:exists?).returns(true)
      File.stubs(:open).returns({:foo => 'bar'}.to_yaml)
      subject.expects(:from_hash)
      subject.load('avalidfile')
    end
  end

  context 'a hash' do
    context 'with :app => {:setting1 => \'foo\', :setting2 => 845}' do
      let(:config) { ConfigLoader.load(:app => {:setting1 => 'foo', :setting2 => 845}) }
      describe 'the class' do
        subject { config }
        its(:config_name) { should eql('app') }
      end

      describe 'the instance' do
        subject { config.new }
        it { should respond_to(:setting1) }
        it { should respond_to(:setting2) }
        it { should_not respond_to(:setting3) }
        its(:setting1) { should eql('foo') }
        its(:setting2) { should eql(845) }
        its(:parent_config) { should be_nil }
      end
    end

    context 'with :group1 => {:setting1 => 6, :setting2 => \'foo\'}, :group2 => {:setting3 => 8, :setting4 => \'bar\'}' do

      let(:config) {
        ConfigLoader.load(
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
      describe 'the class' do
        subject { config }
        its(:config_name) { should eql('root') }
      end
      describe 'the instance' do
        let(:config_inst) { config.new }
        subject { config_inst }
        it { should respond_to(:group1) }
        it { should respond_to(:group2) }
        it { should_not respond_to(:group3) }

        describe 'group1' do
          subject { config_inst.group1 }
          it { should_not be_nil }
          it { should respond_to(:setting1) }
          it { should respond_to(:setting2) }
          it { should_not respond_to(:setting3) }
          its(:setting1) { should eql(6) }
          its(:setting2) { should eql('foo') }
          its(:parent_config) { should eql(config_inst) }
        end

        describe 'group2' do
          subject { config_inst.group2 }
          it { should_not be_nil }
          it { should respond_to(:setting3) }
          it { should respond_to(:setting4) }
          it { should_not respond_to(:setting1) }
          its(:setting3) { should eql(8) }
          its(:setting4) { should eql('bar') }
          its(:parent_config) { should eql(config_inst) }
        end
      end
    end
  end

  context 'something unsupported' do
    subject { ConfigLoader }
    it 'should raise an exception' do
      lambda { subject.load(123) }.should raise_error(ArgumentError)
    end
  end
end

require 'spec_helper'

describe ConfigureMe::Loading, 'a filename' do
  subject { ConfigureMe::Base }
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

describe ConfigureMe::Loading, 'a hash' do
  subject { ConfigureMe::Base }

  context 'with :app => {:setting1 => \'foo\', :setting2 => 845}' do
    before { @config = ConfigureMe::Base.load(:app => {:setting1 => 'foo', :setting2 => 845}) }
    subject { @config.instance }
    its(:config_name) { should eql('app') }

    it { should respond_to(:setting1) }
    it { should respond_to(:setting2) }
    it { should_not respond_to(:setting3) }
    its(:setting1) { should eql('foo') }
    its(:setting2) { should eql(845) }
    its(:parent_config) { should be_nil }
  end

  context 'with :group1 => {:setting1 => 6, :setting2 => \'foo\'}, :group2 => {:setting3 => 8, :setting4 => \'bar\'}' do
    describe 'the instance' do
      before {
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
      }

      subject { @config.instance }
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
        subject { @config.instance.group2 }
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

describe ConfigureMe::Loading, 'something unsupported' do
  subject { ConfigureMe::Base }
  it 'should raise an exception' do
    lambda { subject.load(123) }.should raise_error(ArgumentError)
  end
end

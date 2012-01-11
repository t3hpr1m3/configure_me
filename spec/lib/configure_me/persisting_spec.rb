require 'spec_helper'

describe ConfigureMe::Persisting do

  class PersistingTester
    include ConfigureMe::Persisting
  end
  subject { PersistingTester }
  it { should respond_to(:persist_me) }
  it { should respond_to(:persisting?) }

  let(:persisting_klass) { define_test_class('PersistingConfig', PersistingTester) }

  context 'when the persistence_klass is nil' do
    before {
      persisting_klass.send(:persist_me)
      ConfigureMe.stubs(:persistence_klass).returns(nil)
    }
    subject { persisting_klass }
    its(:persisting?) { should be_false }
  end

  describe 'persist_guard' do
    subject { persisting_klass.new }
    context 'when transactions are supported' do
      it 'should begin a transaction' do
        @transaction_class = mock('TransactionClass') do
          expects(:transaction)
        end
        ConfigureMe.stubs(:persistence_klass).returns(@transaction_class)
        subject.persist_guard
      end
    end

    context 'when persisting with something else' do
      it 'should just execute the block' do
        @non_transaction_class = mock('NonTransactionClass')
        ConfigureMe.stubs(:persistence_klass).returns(@non_transaction_class)
        @testvalue = 'default'
        subject.persist_guard do
          @testvalue = 'changed'
        end
        @testvalue.should eql('changed')
      end
    end
  end

  context 'when persisting is enabled' do
    let(:persisted_setting) { stub(:value => 'foo'.to_yaml, :value= => nil, :save! => nil) }
    before {
      @persistence_klass = stub(:find_or_create_by_key => persisted_setting, :find_by_key => persisted_setting)
      ConfigureMe.stubs(:persistence_klass).returns(@persistence_klass)
      persisting_klass.stubs(:persisting?).returns(true)
    }
    subject { persisting_klass.new }

    describe 'read_persist' do
      before { subject.stubs(:storage_key).returns('key') }
      it 'should read from the persistence store' do
        @persistence_klass.expects(:find_by_key).once.returns(@persisted_setting)
        subject.read_persist('persistedsetting')
      end

      context 'with a persisted value' do
        it 'should return the converted value' do
          subject.read_persist('persistedsetting').should eql('foo')
        end
      end

      context 'with a non-persisted value' do
        it 'should return nil' do
          @persistence_klass.stubs(:find_by_key).returns(nil)
          subject.read_persist('persistedsetting').should be_nil
        end
      end
    end

    describe 'write_persist' do
      before { subject.stubs(:storage_key).returns('key') }
      it 'should retrieve or create the setting' do
        @persistence_klass.expects(:find_or_create_by_key).once.returns(persisted_setting)
        subject.write_persist('persistedsetting', 'newvalue')
      end
      it 'should update the value' do
        persisted_setting.expects(:value=).with('newvalue'.to_yaml)
        subject.write_persist('persistedsetting', 'newvalue')
      end
      it 'should save the record' do
        persisted_setting.expects(:save!)
        subject.write_persist('persistedsetting', 'newvalue')
      end
    end
  end

#describe ConfigureMe::Persisting, 'when persisting is disabled' do
#  before {
#    @persisting_class = define_test_class('PersistingConfig', ConfigureMe::Base)
#    @persisting_class.stubs(:persisting?).returns(false)
#  }
#  subject { @persisting_class.new }
#
#  describe 'read_persist' do
#    it 'should not attempt to read from the persistence store' do
#      ConfigureMe.expects(:persistence_klass).never
#      subject.read_persist('persistedsetting')
#    end
#    it 'should return nil' do
#      subject.read_persist('persistedsetting').should be_nil
#    end
#  end
#
#  describe 'write_persist' do
#    it 'should not attempt to write to the persistence store' do
#      ConfigureMe.expects(:persistence_klass).never
#      subject.write_persist('persistedsetting', 'newvalue')
#    end
#  end
#end
end

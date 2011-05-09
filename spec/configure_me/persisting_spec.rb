require 'spec_helper'

describe ConfigureMe::Persisting, 'the class' do
  subject { ConfigureMe::Base }
  it { should respond_to(:persist_me) }
  it { should respond_to(:persisting?) }

  context 'when the persistence_klass is nil' do
    before {
      @persisting_klass = define_test_class('PersistingConfig', ConfigureMe::Base)
      @persisting_klass.send(:persist_me)
      ConfigureMe.stubs(:persistence_klass).returns(nil)
    }
    subject { @persisting_klass }
    its(:persisting?) { should be_false }
  end

  describe 'persist_guard' do
    before {
      @persisting_klass = define_test_class('PersistingConfig', ConfigureMe::Base)
    }
    subject { @persisting_klass.instance }
    context 'when transactions are supported' do
      it 'should begin a transaction' do
        @transaction_class = mock('TransactionClass') do
          stubs(:transaction)
        end
        ConfigureMe.stubs(:persistence_klass).returns(@transaction_class)
        @transaction_class.expects(:transaction)
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
end

describe ConfigureMe::Persisting, 'when persisting is enabled' do
  before {
    @persisting_class = define_test_class('PersistingConfig', ConfigureMe::Base)
    @persisted_setting = mock('PersistedSetting') do
      stubs(:value).returns('foo'.to_yaml)
      stubs(:value=)
      stubs(:save!)
    end
    @persistence_klass = mock('PersistenceKlass')
    @persistence_klass.stubs(:find_or_create_by_key).returns(@persisted_setting)
    @persistence_klass.stubs(:find_by_key).returns(@persisted_setting)
    ConfigureMe.stubs(:persistence_klass).returns(@persistence_klass)
    @persisting_class.send(:persist_me)
  }
  subject { @persisting_class.instance }

  describe 'read_persist' do
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
    it 'should retrieve or create the setting' do
      @persistence_klass.expects(:find_or_create_by_key).once.returns(@persisted_setting)
      subject.write_persist('persistedsetting', 'newvalue')
    end
    it 'should update the value' do
      @persisted_setting.expects(:value=).with('newvalue'.to_yaml)
      subject.write_persist('persistedsetting', 'newvalue')
    end
    it 'should save the record' do
      @persisted_setting.expects(:save!)
      subject.write_persist('persistedsetting', 'newvalue')
    end
  end
end

describe ConfigureMe::Persisting, 'when persisting is disabled' do
  before {
    @persisting_class = define_test_class('PersistingConfig', ConfigureMe::Base)
    @persisting_class.stubs(:persisting?).returns(false)
  }
  subject { @persisting_class.instance }

  describe 'read_persist' do
    it 'should not attempt to read from the persistence store' do
      ConfigureMe.expects(:persistence_klass).never
      subject.read_persist('persistedsetting')
    end
    it 'should return nil' do
      subject.read_persist('persistedsetting').should be_nil
    end
  end

  describe 'write_persist' do
    it 'should not attempt to write to the persistence store' do
      ConfigureMe.expects(:persistence_klass).never
      subject.write_persist('persistedsetting', 'newvalue')
    end
  end
end

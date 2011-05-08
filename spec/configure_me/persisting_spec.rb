require 'spec_helper'

describe ConfigureMe::Persisting do
  class BasePersistingConfig < BaseTestConfig
    include ConfigureMe::Persisting
  end
  class DummyConfig < BasePersistingConfig; end
  class PersistingConfig < BasePersistingConfig
    persist_me
  end

  class NonPersistingConfig < BasePersistingConfig
  end

  describe 'the class' do
    subject { PersistingConfig }
    it { should respond_to(:persistence_key) }
    it 'should generate a valid persistence key' do
      subject.stubs(:parent_config).returns(nil)
      subject.persistence_key('persistedsetting').should eql('persisting_persistedsetting')
    end
    describe 'persist_me' do
      it 'should raise an exception if the persistence_klass is nil' do
        ConfigureMe.stubs(:persistence_klass).returns(nil)
        lambda { DummyConfig.send(:persist_me) }.should raise_error(RuntimeError)
      end
    end
  end

  describe 'an instance' do
    before {
      @config = PersistingConfig.new
      @config.class.stubs(:parent_config).returns(nil)
    }
    subject { @config }
    it { should respond_to(:write_persist) }
    it { should respond_to(:read_persist) }

    context 'when persisting is disabled' do
      before { @config = NonPersistingConfig.new }
      subject { @config }
      describe 'read_persist' do
        it 'should not attempt to read the setting' do
          ConfigureMe.expects(:persistence_klass).never
          subject.read_persist(:nonpersistedsetting)
        end
      end
      describe 'write_persist' do
        it 'should not attempt to write the setting' do
          ConfigureMe.expects(:persistence_klass).never
          subject.write_persist(:nonpersistedsetting, 'newvalue')
        end
      end
    end

    context 'when persisting is enabled' do
      before {
        @config = PersistingConfig.new
        @persistence_klass = mock('PersistenceKlass')
        ConfigureMe.stubs(:persistence_klass).returns(@persistence_klass)
      }
      subject { @config }
      describe 'read_persist' do
        before(:each) do
          @setting = mock('Setting') do
            stubs(:value).returns('test'.to_yaml)
          end
        end
        it 'should attempt to read the setting' do
          @persistence_klass.expects(:find_by_key)
          subject.read_persist(:persistedsetting)
        end
        it 'should return nil if the setting has not been persisted' do
          @persistence_klass.stubs(:find_by_key).returns(nil)
          subject.read_persist(:persistedsetting).should be_nil
        end
        context 'if the persisted value is non-nil' do
          before(:each) do
            @persistence_klass.stubs(:find_by_key).returns(@setting)
          end
          it 'should convert the YAML value in the datastore' do
            YAML.expects(:load).with('test'.to_yaml)
            subject.read_persist(:persistedsetting)
          end
          it 'should return the converted value' do
            subject.read_persist(:persistedsetting).should eql('test')
          end
        end
      end

      describe 'write_persist' do
        before(:each) do
          @setting = mock('Setting') do
            stubs(:value=)
            stubs(:save!)
          end
        end
        it 'should attempt to find or create the setting' do
          @persistence_klass.expects(:find_or_create_by_key).returns(@setting)
          subject.write_persist(:persistedsetting, 'newvalue')
        end
        it 'should attempt to update the setting' do
          @setting.expects(:value=).with('newvalue'.to_yaml)
          @persistence_klass.stubs(:find_or_create_by_key).returns(@setting)
          subject.write_persist(:persistedsetting, 'newvalue')
        end
        it 'should save the setting after update' do
          @setting.expects(:save!).returns(true)
          @persistence_klass.stubs(:find_or_create_by_key).returns(@setting)
          subject.write_persist(:persistedsetting, 'newvalue')
        end
      end
    end
  end
end

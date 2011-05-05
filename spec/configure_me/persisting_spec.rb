require 'spec_helper'

describe ConfigureMe::Persisting do
  class Setting; end
  class PersistingConfig < ConfigureMe::Base
    setting :persistedsetting, :type => :string, :default => 'persisted'
    persist_me
  end

  class NonPersistingConfig < ConfigureMe::Base
    setting :nonpersistedsetting, :type => :string, :default => 'nonpersisted'
  end

  describe 'the class' do
    subject { PersistingConfig }
    it { should respond_to(:persistence_key) }
    it 'should generate a valid persistence key' do
      subject.persistence_key('persistedsetting').should eql('persisting_persistedsetting')
    end
  end

  describe 'an instance' do
    subject { PersistingConfig.instance }
    it { should respond_to(:write_persist) }
    it { should respond_to(:read_persist) }

    context 'when persisting is disabled' do
      subject { NonPersistingConfig.instance }
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
      before(:each) do
        @persistence_klass = mock('PersistenceKlass')
        ConfigureMe.stubs(:persistence_klass).returns(@persistence_klass)
        @setting = mock('Setting') do
          stubs(:value).returns('test'.to_yaml)
        end
      end
      subject { PersistingConfig.instance }
      describe 'read_persist' do
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
          it 'should attempt to cache the converted value' do
            subject.expects(:write_cache).with(:persistedsetting, 'test')
            subject.read_persist(:persistedsetting)
          end
          it 'should store the converted value in the @settings hash' do
            subject.read_persist(:persistedsetting)
            subject.instance_variable_get(:@settings)[:persistedsetting].should eql('test')
          end
        end
      end
    end
  end
end

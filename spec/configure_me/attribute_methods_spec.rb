require 'spec_helper'

describe ConfigureMe::AttributeMethods do
  class BaseAttributeConfig < BaseTestConfig
    include ConfigureMe::AttributeMethods

    setting :testsetting, :default => 'foo'
  end

  context 'class' do
    subject { BaseAttributeConfig }
    it { should respond_to(:setting) }
    it { should respond_to(:class_settings) }
    its(:class_settings) { should_not be_empty }
    it { should respond_to(:define_attribute_methods) }
  end

  before { @config = BaseAttributeConfig.new }
  subject { @config }
  it { should respond_to(:changed?) }
  its(:changed?) { should be_false }
  it { should respond_to(:testsetting_changed?) }
  its(:testsetting_changed?) { should be_false }
  its(:temp_attributes) { should be_empty }

  describe 'reading an attribute' do
    before {
      @config.stubs(:read_cache)
      @config.stubs(:read_persist)
    }
    context 'with a pristine instance' do
      it 'should attempt to read from the cache' do
        subject.expects(:read_cache)
        subject.testsetting
      end
      it 'should attempt to read from the persistence store' do
        subject.expects(:read_persist)
        subject.testsetting
      end
      it 'should return the default value' do
        subject.testsetting.should eql('foo')
      end
    end
    context 'with a persisted value' do
      context 'with a non-cached value' do
        before { @config.stubs(:read_cache).returns(nil) }
        it 'should attempt to read from the cache' do
          subject.expects(:read_cache).returns(nil)
          subject.testsetting
        end
        it 'should attempt to read from the persistence store' do
          subject.expects(:read_persist)
          subject.testsetting
        end
        it 'should write the value to the cache' do
          subject.stubs(:read_persist).returns('persisted')
          subject.expects(:write_cache).with(:testsetting, 'persisted')
          subject.testsetting
        end
        it 'should return the persisted value' do
          subject.stubs(:read_cache).returns('persisted')
          subject.testsetting.should eql('persisted')
        end
      end

      context 'with a cached value' do
        before { @config.stubs(:read_cache).returns('cached') }
        it 'should attempt to read from the cache' do
          subject.expects(:read_cache).returns('cached')
          subject.testsetting
        end
        it 'should not attempt to read from the persistence store' do
          subject.expects(:read_persist).never
          subject.testsetting
        end
        it 'should return the cached value' do
          subject.testsetting.should eql('cached')
        end
      end
    end

    context 'with a dirty value' do
      before { @config.stubs(:testsetting_changed?).returns(true) }
      it 'should not attempt to read from the cache' do
        subject.expects(:read_cache).never
        subject.testsetting
      end
      it 'should not attempt to read from the persistence store' do
        subject.expects(:read_persist).never
        subject.testsetting
      end
      it 'should return the value from the temp_attributes hash' do
        subject.expects(:temp_attributes).returns(:testsetting => 'iamdirty')
        subject.testsetting.should eql('iamdirty')
      end
    end
  end

  describe 'writing an attribute' do
    before {
      @config.stubs(:read_cache)
      @config.stubs(:read_persist)
    }
    it 'should set the model to dirty' do
      subject.testsetting = 'newvalue'
      subject.changed?.should be_true
    end
    it 'should set the attribute to dirty' do
      subject.testsetting = 'newvalue'
      subject.testsetting_changed?.should be_true
    end
    it 'should write the value to the temp_attributes hash' do
      subject.testsetting = 'newvalue'
      subject.send(:temp_attributes)[:testsetting].should eql('newvalue')
    end
  end

  describe 'saving' do
    before {
      @config.stubs(:read_cache)
      @config.stubs(:read_persist)
      @config.stubs(:write_cache)
      @config.stubs(:write_persist)
    }
    before { @config.testsetting = 'newvalue' }
    it 'should start a transaction' do
      ActiveRecord::Base.expects(:transaction)
      subject.save
    end

    it 'should persist the temp settings' do
      ActiveRecord::Base.stubs(:transaction).yields
      subject.expects(:write_persist).with(:testsetting, 'newvalue')
      subject.save
    end

    it 'should cache the temp settings' do
      ActiveRecord::Base.stubs(:transaction).yields
      subject.expects(:write_cache).with(:testsetting, 'newvalue')
      subject.save
    end

    it 'should clear the temp settings' do
      ActiveRecord::Base.stubs(:transaction).yields
      subject.save
      subject.send(:temp_attributes).should be_empty
    end

    it 'should reset the dirty status on the model' do
      ActiveRecord::Base.stubs(:transaction).yields
      subject.save
      subject.changed?.should be_false
    end

    it 'should reset the dirty status on the attribute' do
      ActiveRecord::Base.stubs(:transaction).yields
      subject.save
      subject.testsetting_changed?.should be_false
    end
  end

  describe 'update_attributes' do
    before {
      @config.stubs(:attribute)
    }
    it 'should store the new attributes' do
      subject.stubs(:save)
      subject.expects(:attribute=).with(:testsetting, 'updatedvalue')
      subject.update_attributes(:testsetting => 'updatedvalue')
    end

    it 'should attempt to save' do
      subject.expects(:save)
      subject.update_attributes(:testsetting => 'updatedvalue')
    end
  end
end

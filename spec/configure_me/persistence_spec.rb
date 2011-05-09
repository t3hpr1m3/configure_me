require 'spec_helper'

describe ConfigureMe::Persistence do
  before {
    @persistence_class = define_test_class('PersistenceConfig', ConfigureMe::Base)
    @config = @persistence_class.instance
  }
  subject { @config }
  describe 'saving' do
    before {
      @config.stubs(:write_persist)
      @config.stubs(:write_cache)
      @config.stubs(:make_clean)
      @temp_attrs = {:testsetting => 'newvalue'}
      @config.stubs(:temp_attributes).returns(@temp_attrs)
      @config.stubs(:persist_guard).yields
    }
    it 'should run callbacks' do
      @config.expects(:run_callbacks).at_least_once.yields
      @config.save
    end
    it 'should not run the validations if :validate => false is passed' do
      @config.expects(:valid?).never
      @config.save(:validate => false)
    end
    it 'should start a transaction' do
      @config.expects(:persist_guard)
      @config.save
    end

    it 'should persist the temp settings' do
      @config.expects(:write_persist).with(:testsetting, 'newvalue')
      @config.save
    end

    it 'should cache the temp settings' do
      @config.expects(:write_cache).with(:testsetting, 'newvalue')
      @config.save
    end

    it 'should clear the dirty status' do
      @config.expects(:make_clean)
      @config.save
    end
  end

  describe 'update_attributes' do
    before {
      @config.stubs(:write_attribute)
    }
    it 'should store the new attributes' do
      @config.stubs(:save)
      @config.expects(:write_attribute).with(:testsetting, 'updatedvalue')
      @config.update_attributes(:testsetting => 'updatedvalue')
    end

    it 'should attempt to save' do
      @config.expects(:save)
      @config.update_attributes(:testsetting => 'updatedvalue')
    end
  end
end

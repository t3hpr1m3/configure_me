require 'spec_helper'

describe ConfigureMe::AttributeMethods do
  class AttributeTester
    include ConfigureMe::AttributeMethods
  end

  let(:test_class) { define_test_class('MyTestConfig', AttributeTester) }
  subject { test_class.new }
  it 'make_clean should clear the temp_attributes' do
    subject.send(:temp_attributes).expects(:clear)
    subject.send(:make_clean)
  end

  describe 'reading an attribute' do
    before {
      test_class.send(:setting, :testsetting, :default => 'foo')
      @config = test_class.new
      @config.stubs(:read_cache)
      @config.stubs(:read_persist)
    }
    subject { @config }
    it 'should call "read_attribute"' do
      @config.expects(:read_attribute).with('testsetting')
      subject.testsetting
    end
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
      test_class.send(:setting, :testsetting, :default => 'foo')
      @config = test_class.new
      @config.stubs(:read_cache)
      @config.stubs(:read_persist)
    }
    subject { @config }

    it 'should set the attribute to dirty' do
      subject.expects(:make_dirty).with(:testsetting)
      subject.testsetting = 'newvalue'
    end
    it 'should write the value to the temp_attributes hash' do
      subject.testsetting = 'newvalue'
      subject.send(:temp_attributes)[:testsetting].should eql('newvalue')
    end
  end
end

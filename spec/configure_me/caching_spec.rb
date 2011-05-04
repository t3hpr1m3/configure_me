require 'spec_helper'

describe ConfigureMe::Caching do
  class CachingConfig < ConfigureMe::Base
    setting :cachingsetting, :type => :string, :default => 'mydefault'
    cache_me
  end

  class NonCachingConfig < ConfigureMe::Base
    setting :noncachingsetting, :type => :string, :default => 'noncache'
  end

  describe "the class" do
    subject { CachingConfig }
    it { should respond_to(:cache_key) }
    it 'should generate a valid cache key' do
      subject.cache_key('mydefault').should eql('caching_mydefault')
    end
  end

  describe "an instance" do
    subject { CachingConfig.instance }
    it { should respond_to(:write_cache) }
    it { should respond_to(:read_cache) }

    context 'when Rails.cache is defined' do
      before(:each) do
        if Object.const_defined?('Rails')
          Object.send :remove_const, :Rails
        end
        Object.const_set('Rails', Class.new(Object))
      end
      context 'and caching is disabled' do
        subject { NonCachingConfig.instance }
        describe 'read_cache' do
          it 'should not attempt to read from the cache' do
            Rails.expects(:cache).never
            subject.read_cache('noncachingsetting')
          end
          it 'should return nil' do
            subject.read_cache('noncachingsetting').should be_nil
          end
        end

        describe 'write_cache' do
          it 'should not attempt to write to the cache' do
            Rails.expects(:cache).never
            subject.write_cache('noncachingsetting', 'foobar')
          end
        end
      end

      context 'and caching is enabled' do
        subject { CachingConfig.instance }
        describe 'read_cache' do
          before(:each) do
            @reader = mock('reader') do
              stubs(:read).returns('cachedvalue')
            end
          end
          it 'should attempt to read from the cache' do
            Rails.expects(:cache).returns(@reader)
            subject.read_cache('cachingsetting')
          end
          it 'should return the cached value' do
            Rails.stubs(:cache).returns(@reader)
            subject.read_cache('cachingsetting').should eql('cachedvalue')
          end
        end

        describe 'write_cache' do
          it 'should attempt to write to the cache' do
            writer = mock('writer') do
              stubs(:write)
            end
            Rails.expects(:cache).once.returns(writer)
            subject.write_cache('cachingsetting', 'foobar')
          end
        end
      end
    end

    context 'when Rails is not defined' do
      before(:each) do
        if Object.const_defined?('Rails')
          Object.send :remove_const, :Rails
        end
      end
      context 'and caching is disabled' do
        subject { NonCachingConfig.instance }
        describe 'read_cache' do
          it 'should not attempt to read from the cache' do
            subject.class.expects(:cache_key).never
            subject.read_cache('noncachingsetting')
          end
          it 'should return nil' do
            subject.read_cache('noncachingsetting').should be_nil
          end
        end

        describe 'write_cache' do
          it 'should not attempt to write to the cache' do
            subject.class.expects(:cache_key).never
            subject.write_cache('noncachingsetting', 'foobar')
          end
        end
      end

      context 'and caching is enabled' do
        subject { CachingConfig.instance }
        describe 'read_cache' do
          it 'should not attempt to read from the cache' do
            subject.class.expects(:cache_key).never
            subject.read_cache('cachingsetting')
          end
          it 'should return nil' do
            subject.read_cache('cachingsetting').should be_nil
          end
        end

        describe 'write_cache' do
          it 'should not attempt to write to the cache' do
            subject.class.expects(:cache_key).never
            subject.write_cache('cachingsetting', 'foobar')
          end
        end
      end
    end
  end
end

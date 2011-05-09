require 'spec_helper'

describe ConfigureMe::Caching, 'the class' do
  subject { ConfigureMe::Base }
  it { should respond_to(:cache_me) }
  it { should respond_to(:caching?) }
end

describe ConfigureMe::Caching, 'caching?' do
  before {
    @caching_class = define_test_class('CachingConfig', ConfigureMe::Base)
    @caching_class.send(:cache_me)
  }
  subject { @caching_class }

  context 'when cache_object is available' do
    before { ConfigureMe.stubs(:cache_object).returns({}) }
    specify { subject.caching?.should be_true }
  end

  context 'when cache_object is unavailable' do
    before { ConfigureMe.stubs(:cache_object).returns(nil) }
    specify { subject.caching?.should be_false }
  end

end

describe ConfigureMe::Caching, 'when caching is enabled' do
  before {
    @caching_class = define_test_class('CachingConfig', ConfigureMe::Base)
    @caching_class.stubs(:caching?).returns(true)
    @cache_object = mock('CacheObject') do
      stubs(:read).returns('cached_value')
      stubs(:write)
    end
    ConfigureMe.stubs(:cache_object).returns(@cache_object)
  }
  subject { @caching_class.instance }

  it 'should attempt to read from the cache' do
    ConfigureMe.expects(:cache_object).once.returns(@cache_object)
    subject.read_cache('cachedsetting')
  end

  it 'should return the value from the cache' do
    subject.read_cache('cachedsetting').should eql('cached_value')
  end

  it 'should attempt to write to the cache' do
    @cache_object.expects(:write).once
    subject.write_cache('cachedsetting', 'newvalue')
  end
end

describe ConfigureMe::Caching, 'when caching is disabled' do
  before {
    @caching_class = define_test_class('CachingConfig', ConfigureMe::Base)
    @caching_class.stubs(:caching?).returns(false)
  }
  subject { @caching_class.instance }

  it 'should not attempt to read from the cache' do
    ConfigureMe.expects(:cache_object).never
    subject.read_cache('cachedsetting')
  end

  it 'should return nil when read_cache is called' do
    subject.read_cache('cachedsetting').should be_nil
  end

  it 'should not attempt to write to the cache' do
    ConfigureMe.expects(:cache_object).never
    subject.write_cache('cachedsetting', 'newvalue')
  end
end

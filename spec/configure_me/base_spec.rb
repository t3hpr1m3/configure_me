require 'spec_helper'

describe ConfigureMe::Base do
  class TestConfig < ConfigureMe::Base
  end

  it { TestConfig.should respond_to(:setting) }
  it { should respond_to(:read_setting) }
  it { should respond_to(:write_setting) }
  it { TestConfig.send(:persisting?).should be_false }

  describe 'with a "color" setting with a default of "red"' do
    before(:each) do
      @klass = Class.new(ConfigureMe::Base)
      @klass.send :setting, :color, :string, :default => 'red'
    end

    describe 'an instance ' do
      it 'should respond to attribute_method?(:color) with true' do
        @obj = @klass.new
        @obj.send(:attribute_method?, :color).should be_true
      end

      it 'should respond to attribute_method?(:size) with false' do
        @obj = @klass.new
        @obj.send(:attribute_method?, :size).should be_false
      end

      it 'should respond to :color with "red"' do
        @obj = @klass.new
        @obj.color.should eql('red')
      end

      it 'should store a new :color of "blue"' do
        @obj = @klass.new
        @obj.color = 'blue'
        @obj.color.should eql('blue')
      end

      it 'should raise error when setting an unknown attribute' do
        @obj = @klass.new
        lambda { @obj.write_setting('size', 'big') }.should raise_error(NoMethodError)
      end

      it 'should assign from a hash' do
        @obj = @klass.new
        @obj.send :settings=, {:color => 'blue'}
        @obj.color.should eql('blue')
      end
    end
  end

  describe 'persisting' do
    describe 'with PersistedSetting' do
      require 'active_record'
      before(:each) do
        @klass = TestConfig
        @klass.send :setting, :color, :string, :default => 'red'
        @klass.send :persist_me
      end

      it { @klass.send(:persisting?).should be_true }
      it { @klass.should respond_to(:persistence_key) }
      it { @klass.persistence_key.should eql('test') }

      describe 'with a non-persisted setting' do
        before(:each) do
          @obj = @klass.new
          @persisted = mock('PersistedSetting') do
            stubs(:value=)
            stubs(:save!)
          end
          ConfigureMe::PersistedSetting.stubs(:find_by_key).returns(nil)
          ConfigureMe::PersistedSetting.stubs(:find_or_create_by_key).returns(@persisted)
        end

        it { @obj.send(:persistence_key, :color).should eql('test_color') }

        it 'should store updates to the database' do
          mock('PersistedSetting') do
            stubs(:key)
            stubs(:value)
          end
          @obj.color = "blue"
        end

        it 'should return the default value' do
          @obj.color.should eql('red')
        end
      end

      describe 'with a persisted setting' do
        before(:each) do
          @obj = @klass.new
          @persisted = mock('PersistedSetting') do
            stubs(:value).returns("blue".to_yaml)
          end
          ConfigureMe::PersistedSetting.stubs(:find_by_key).returns(@persisted)
        end
        
        it 'should return a valid value' do
          @obj.color.should eql("blue")
        end
      end
    end
  end
end

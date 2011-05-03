require 'spec_helper'

describe ConfigureMe::Setting do
  class TestConfig < ConfigureMe::Base
  end

  def mock_setting(name, *args)
    ConfigureMe::Setting.new(TestConfig, name, *args)
  end

  describe 'an instance' do
    subject do
      mock_setting(:foo, :type => :string, :default => 'bar')
    end
    it { should respond_to(:name) }
    it { should respond_to(:type) }
    it { should respond_to(:default) }
    its(:name) { should eql('foo') }
    its(:type) { should eql(:string) }
    its(:default) { should eql('bar') }
  end

  describe 'inferring the type' do
    context 'with a string default value' do
      subject do
        mock_setting(:foo, :default => 'stringvalue')
      end
      its(:type) { should eql(:string) }
      its(:default) { should eql('stringvalue') }
    end
    context 'with a numeric default value' do
      subject do
        mock_setting(:foo, :default => 123)
      end
      its(:type) { should eql(:integer) }
      its(:default) { should eql(123) }
    end
    context 'with a float default value' do
      subject do
        mock_setting(:foo, :default => 1.23)
      end
      its(:type) { should eql(:float) }
      its(:default) { should eql(1.23) }
    end
    context 'with a boolean default value' do
      subject do
        mock_setting(:foo, :default => true)
      end
      its(:type) { should eql(:boolean) }
      its(:default) { should eql(true) }
    end
    context 'with a nil default value' do
      subject do
        mock_setting(:foo, :default => nil)
      end
      its(:type) { should eql(:unknown) }
      its(:default) { should be_nil }
    end
    context 'with an unsupported default value' do
      it 'should raise an exception' do
        lambda {
          ConfigureMe::Setting.new(TestConfig, :foo, :default => {:invalid => 'hash'})
        }.should raise_error(ConfigureMe::InvalidDefault)
      end
    end
  end

  describe 'convert' do
    before(:each) do
      @string_setting   = mock_setting(:stringsetting, :type => :string)
      @integer_setting  = mock_setting(:integersetting, :type => :integer)
      @float_setting    = mock_setting(:floatsetting, :type => :float)
      @boolean_setting  = mock_setting(:booleansetting, :type => :boolean)
    end
    context 'an empty string' do
      it 'should return "" with a string type' do
        @string_setting.convert('').should eql('')
      end
      it 'should return 0 with an integer type' do
        @integer_setting.convert('').should eql(0)
      end
      it 'should return 0.0 with a float type' do
        @float_setting.convert('').should eql(0.0)
      end
      it 'should return nil with a boolean type' do
        @boolean_setting.convert('').should be_nil
      end
    end
    context 'a string value of "foo"' do
      it 'should return "foo" with a string type' do
        @string_setting.convert('foo').should eql('foo')
      end
      it 'should return 0 with an integer type' do
        @integer_setting.convert('foo').should eql(0)
      end
      it 'should return 0.0 with a float type' do
        @float_setting.convert('foo').should eql(0.0)
      end
      it 'should return false with a boolean type' do
        @boolean_setting.convert('foo').should be_false
      end
    end

    context 'an integer value of 123' do
      it 'should return "123" with a string type' do
        @string_setting.convert(123).should eql('123')
      end
      it 'should return 123 with an integer type' do
        @integer_setting.convert(123).should eql(123)
      end
      it 'should return 123.0 with a float type' do
        @float_setting.convert(123).should eql(123.0)
      end
      it 'should return false with a boolean type' do
        @boolean_setting.convert(123).should be_false
      end
    end

    context 'a float value of 1.23' do
      it 'should return "1.23" with a string type' do
        @string_setting.convert(1.23).should eql('1.23')
      end
      it 'should return 1 with an integer type' do
        @integer_setting.convert(1.23).should eql(1)
      end
      it 'should return 1.23 with a float type' do
        @float_setting.convert(1.23).should eql(1.23)
      end
      it 'should return false with a boolean type' do
        @boolean_setting.convert(1.23).should be_false
      end
    end

    context 'a boolean value of true' do
      it 'should return "true" with a string type' do
        @string_setting.convert(true).should eql('true')
      end
      it 'should return 1 with an integer type' do
        @integer_setting.convert(true).should eql(1)
      end
      it 'should return 1.0 with a float type' do
        @float_setting.convert(true).should eql(1.0)
      end
      it 'should return true with a boolean type' do
        @boolean_setting.convert(true).should be_true
      end
    end

    context 'a nil value' do
      it 'should return "" with a string type' do
        @string_setting.convert(nil).should eql('')
      end
      it 'should return 0 with an integer type' do
        @integer_setting.convert(nil).should eql(0)
      end
      it 'should return 0.0 with a float type' do
        @float_setting.convert(nil).should eql(0.0)
      end
      it 'should return false with a boolean type' do
        @boolean_setting.convert(nil).should be_false
      end
    end

    describe 'to string with an unsupported type' do
      it 'should raise InvalidConversion' do
        lambda { @string_setting.convert([]) }.should raise_error(ConfigureMe::InvalidConversion)
      end
    end

    describe 'with an unknown type' do
      before(:each) do
        @unknown = mock_setting(:unknownsetting, :default => nil)
      end
      it 'should set the type to :string when a string value is converted' do
        @unknown.convert('string')
        @unknown.type.should eql(:string)
      end
      it 'should set the type to :integer when an integer value is converted' do
        @unknown.convert(123)
        @unknown.type.should eql(:integer)
      end
      it 'should set the type to :float when a float value is converted' do
        @unknown.convert(1.23)
        @unknown.type.should eql(:float)
      end
      it 'should set the type to :boolean when a boolean value is converted' do
        @unknown.convert(true)
        @unknown.type.should eql(:boolean)
      end
    end
  end
end

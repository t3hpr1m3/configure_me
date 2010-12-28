require 'spec_helper'

describe ConfigureMe::Setting do
  before(:each) do
    @owner = mock('owner') do
      stubs(:define_attribute_methods)
    end
    @setting = ConfigureMe::Setting.new(@owner, :foo, :default => 'bar')
  end

  it { @setting.should respond_to(:name) }
  it { @setting.name.should eql('foo') }
  it { @setting.should respond_to(:default) }
  it { @setting.default.should eql('bar') }

  it "define_methods! should call the owner class's define_attribute_methods with false" do
    owner = mock('owner') do
      expects(:define_attribute_methods).with(true)
    end
    setting = ConfigureMe::Setting.new(owner, :foo, :default => 'bar')
    setting.define_methods!
  end
end

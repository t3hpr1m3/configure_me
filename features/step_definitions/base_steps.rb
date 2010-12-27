require 'configure_me'

Given /^a (.*) class that derives from ConfigureMe::Base$/ do |name|
  @klass = Class.new(ConfigureMe::Base)
end

Given /^I add a "([^"]*)" setting with a type of "([^"]*)" and a default of "([^"]*)"$/ do |name, type, default|
  @klass.send :setting, name.to_sym, type.to_sym, :default => default
end

When /^I create an instance of the class$/ do
  @obj = @klass.new
end

When /^I create another instance of the class$/ do
  @obj2 = @klass.new
end

When /^I read the "([^"]*)" setting$/ do |name|
  @result = @obj.send name.to_sym
end

When /^I read the new class's "([^"]*)" setting$/ do |name|
  @result = @obj2.send name.to_sym
end

When /^I set the "([^"]*)" setting to "([^"]*)"$/ do |name, value|
  @obj.send "#{name}=".to_sym, value
end

Then /^the result should be "([^"]*)"$/ do |value|
  @result.should eql(value)
end

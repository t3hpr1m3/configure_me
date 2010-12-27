Feature: Store configuration in memory
	In order to store configuration information
	As a ruby developer
	I want to create a configuration class that stores settings in memory

	Scenario: Simple configuration object
		Given a Configuration class that derives from ConfigureMe::Base
		And I add a "color" setting with a type of "string" and a default of "red"
		When I create an instance of the class
		And I read the "color" setting
		Then the result should be "red"

		When I set the "color" setting to "blue"
		And I read the "color" setting
		Then the result should be "blue"


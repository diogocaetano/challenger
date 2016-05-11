require "bundler/setup"	
require "test_notifier/runner/rspec"

Bundler.require()

RSpec.configure do |config|
	
	TestNotifier.default_notifier = :growl

	config.expect_with :rspec do |c|
		c.syntax = :expect
	end
end

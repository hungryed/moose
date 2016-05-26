# Moose
(currently named meese to not conflict with an existing namespace)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'moose'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install moose

## Usage

```bash
bundle exec moose {ENVIRONMENT_NAME}
```

for example
```bash
bundle exec moose beta
```

## Directory structure
```
|--app
|--spec
|--moose_tests
  |--app_one_suite
  | |--app_one_tests
  | | |--lib
  | | |--locators
  | | | |--creative_directory_locators
  | | | | |--creative_locators.yml
  | | | | |--better_creative_locators.yml
  | | | |--some_locators.yml
  | | |--test_groups
  | | | |--creative_directory_name
  | | | | |--test_cases
  | | | | | |--test_case_definition.rb
  | | | | | |--another_test_case_definition.rb
  | | | | |--creative_directory_configuration.rb
  | | | |--another_very_creative_directory_name
  | | | | |--test_cases
  | | | | | |--hey_look_a_test.rb
  | | | | | |--oh_man_a_test.rb
  | | | |--app_one_tests_configuration.rb
  |--other_app_suite
  | |--other_app_tests
  |   |--lib
  |   |--locators
  |   |--test_groups
  |--moose_configuration.rb
```

## Configurations

### Moose Configuration
Defined in the `moose_tests` folder as `moose_configuration.rb`

```ruby
Moose.configure do |config|

  # HOOKS
  config.add_before_run_hook do |moose|
    puts "in base config before run hook"
  end

  config.add_after_run_hook do |moose|
    puts "in base config before run hook"
  end

  config.before_each_test_case do |test_case|
    puts "in base config before test case hook"
  end

  config.after_each_test_case do |test_case|
    puts "in base config after test case hook"
  end

  # OPTIONS
  # DEFAULTS = {
  #   :verbose => false,
  #   :log_directory => "",
  #   :snapshot_directory => "snapshots",
  #   :snapshots => false,
  #   :moose_test_group_directory_pattern => "test_groups/**",
  #   :suite_pattern => "*_suite/",
  #   :run_in_threads => false,
  #   :test_thread_count => 5,
  #   :headless => false,
  #   :browser => :chrome,
  #   :rerun_failed => false,
  # }

  config.verbose = true
  config.run_in_threads = true
  config.test_thread_count = 5
end

```


### Test Suite Configuration
Defined in the test suite directory
This is where you set your base url for this test suite

```ruby
Moose.configure_suite do |config|
  # REGISTER ENVIRONMENTS

  [
    {
      :beta => {
        :base_url => "https://beta.example.com",
        :api_token =>  "abcde-12345"
      }
    },
    {
      :alpha => {
        :base_url => "https://alpha.example.com",
        :api_token =>  "12345-abcde"
      }
    },
  ].each do |environment, environment_details|
    config.register_environment(environment, environment_details)
  end


  # HOOKS

  config.before_each_test_case do |test_case|
    puts "in suite before test case hook"
  end

  config.after_each_test_case do |test_case|
    puts "in suite after test case hook"
  end

  config.add_before_suite_hook do |test_suite|
    puts "in suite before suite hook"
  end

  config.add_after_suite_hook do |test_suite|
    puts "in suite after suite hook"
  end
end

```
### Test Group Configuration
Defined in the test group directory
This is where you can set your test group hooks for a smaller set of tests

```ruby
Moose.configure_test_group do |config|
  config.add_before_hook do |test_case|
    puts "in test case before hook"
  end

  config.add_after_hook do |test_case|
    puts "in test case after hook"
  end

  #OPTIONS
  config.run_in_threads = true # Default nil
end

```


## Test Case

```ruby
Moose.define_test_case do
  # test case logic goes here
end
```

#### Each test case can have multiple browsers
```ruby
Moose.define_test_case do
  browser #will return the latest browser or spin up new browser with the current test suite's locators
  new_browser # spins up a new browser with the current test suite's locators
  new_browser(:browser => :firefox) # spins up a new firefox browser with the current test suite's locators
  new_browser(:headless => true) # spins up a headless browser
  browser(index: 0) #will return first browser

  run_as(OTHER_SUITE_NAME) do |suite_instance, suite_browser|

  end

  # run block without browser
  run_as(API_SUITE_NAME, :needs_browser => false) do |suite_instance|

  end
end
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


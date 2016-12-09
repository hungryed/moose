# Moose: The Facts And The Myths

Add the Moose gem to your application's Gemfile:

```ruby
gem 'moose'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install moose

## Usage

In order to run the entire directory of Moose tests (e.g. all included test suites), execute:

```bash
bundle exec moose {ENVIRONMENT_NAME}
```

For example:
```bash
bundle exec moose beta
```

To specify a particular directory of tests to run, execute:

```bash
bundle exec moose beta moose_tests/path/to/test_suite/
```

To get more specific, you can target a single test group to execute:
```bash
bundle exec moose beta moose_tests/path/to/test_suite/and/test_group/
```

To use the most granular option, you can target a single test case to execute:
```bash
bundle exec moose beta moose_tests/path/to/test_suite/and/test_group/specific_test_case.rb
```

## Generic Directory Structure
```
|--app
|--spec
|--moose_tests
| |--app_one_suite
| | |--lib
| | | |--pages
| | | | |--home
| | | | | |--search_page.rb
| | | | |--menu
| | | | | |--user_menu_section.rb
| | | |--flows
| | | | |--search_flow.rb
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
| |--other_app_suite
| | |--lib
| | |--test_groups
| |--moose_configuration.rb
```

## Configurations

### Moose Configuration
Defined in the `moose_tests` folder as `moose_configuration.rb`.

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

  config.around_each_test_case do |test_case, blk|
    puts "in base config around test case hook before call"
    blk.call
    puts "in base config around test case hook after call"
  end

  # OPTIONS
  # DEFAULTS = {
  #   :verbose => false,
  #   :snapshot_directory => "snapshots",
  #   :snapshots => false,
  #   :moose_test_group_directory_pattern => "test_groups/**",
  #   :suite_pattern => "*_suite/",
  #   :run_in_threads => false,
  #   :test_thread_count => 5,
  #   :headless => false,
  #   :browser => :chrome,
  #   :rerun_failed => false,
  #   :show_full_error_backtrace => false,
  #   :test_status_persistence_directory => nil,
  # }

  config.verbose = true
  config.run_in_threads = true
  config.test_thread_count = 5
  config.test_status_persistence_directory = File.expand_path("tmp", __FILE__)
end

```

Under the above implemention, to designate a global config option you would need to add a `config.SPECIFY_DESIRED_OPTION` line in the moose_configuration.rb file--but this necessarily affects every test you run, which may be an undesirable outcome. To run options on an as-needed basis, specify them in the command line. You can run `moose --help` to see the available configuration options.

For example:

```bash
bundle exec moose --headless
```

### Moose Message Configuration

```ruby
Moose.msg.configure do |config|
  # OPTIONS
  # COLOR_DEFAULTS = {
  #   :failure_font_color => :white,
  #   :failure_background_color => :red,
  #   :pass_font_color => :white,
  #   :pass_background_color => :green,
  #   :pending_font_color => :white,
  #   :pending_background_color => :magenta,
  #   :skipped_font_color => :white,
  #   :skipped_background_color => :light_red,
  #   :incomplete_font_color => :white,
  #   :incomplete_background_color => :yellow,
  #   :invert_font_color => :white,
  #   :invert_background_color => :black,
  #   :name_font_color => :white,
  #   :name_background_color => :cyan,
  #   :case_description_font_color => :cyan,
  #   :banner_font_color => :blue,
  #   :info_font_color => :blue,
  #   :header_font_color => :cyan,
  #   :warn_font_color => :yellow,
  #   :error_font_color => :red,
  #   :step_font_color => :yellow,
  #   :dot_font_color => :yellow,
  # }

  config.info_font_color = :green
end

```


### Test Suite Configuration
This config is located in the `#{app}_suite` directory for each individual suite. The base URLs to execute tests in specific environments (e.g. beta, staging) are defined here, as well as API tokens and any hooks you want to be run before or after the test suite is executed.

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

  config.around_each_test_case do |test_case, blk|
    puts "in suite around test case hook before call"
    blk.call
    puts "in suite around test case hook after call"
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
The config file for test groups is defined in the `#{app}_group` directory. This is where you can set hooks for a single group of tests, as opposed to a global hook run before or after the entire suite.

```ruby
Moose.configure_test_group do |config|
  config.add_before_hook do |test_case|
    puts "in test case before hook"
  end

  config.add_after_hook do |test_case|
    puts "in test case after hook"
  end

  config.add_around_hook do |test_case, blk|
    puts "in around test case hook before call"
    blk.call
    puts "in around test case hook after call"
  end

  #OPTIONS
  config.run_in_threads = true # Default nil
end

```

### Test Case Setup

```ruby
Moose.define_test_case do
  # test case logic goes here
  # test case should try and use Flows for the logic
end
```

### Page Configuration

Pages are the files where the elements and single interactions are defined within Moose.
Pages contains Elements, can contain one more Moose::Page::Section
Pages will be used in Moose::Flows
Elements and Sections can be used as a method call within the same Page.
When using Sections, you only have to require the files when the namespace of the section is different then the name space of the Page
```ruby
require_relative '../menu/user_menu_section.rb'
module Application
  module Home
    class SearchPage < Moose::Page::Full
      self.path '/search'
      element(:a_element) { browser.a(:id, 'link_somewhere') }
      section(:search_results, Application::Home::SearchRestultSection) { browser }
      section(:different_name_space, Application::Menu::UserMenuSection) { browser }
      def click_on_a
        a_element.click
      end

      def click_on_result
        search_results.result.click
      end
    end
  end
end
```

### Section Configuration

Sections are similar to Pages, except the Moose inheritance is different and that they contain no path
It is required for the Page instanciating the Section to pass a block with the browser or the element wrapping the section you are breaking off the Page.
Sections exist to DRY the page and keep the file smaller.
Sections can contain sections if you deem necessary

```ruby
module Application
  module Home
    class SearchResultSection < Moose::Page::Section
      element(:result) { browser.a(:id, 'result_1') }
    end
  end
end
```

### Flow Configuration

Flows are in place to DRY the test cases, having test cases contain logic leads to copy paste, keeping the logic on the flow, ensures that a change in test logic spans across multiple test cases.

Also, a Flow is not only a single interaction with an Element on a Page, it is a set of interactions that lead to a result.
Almost always a Flow method should return something to the Test Case.

Flows can contain more than one page. You can instantiate a Flow within a Flow like instantianting a new Class in plain ruby.
```ruby
module Application
  module Home
    class SearchFlow < Moose::Flow
    # :browser is always a required initiliazing attribute
      initial_attributes(:test_case) # adds required initializer attributes
      page(:search_page, Application::Home::SearchPage)

      def open_link
        search_page.click_on_a
      end

    end
  end
end

# Instantiating a Flow

Application::Home::SearchFlow.new(
    :browser => browser
    :test_case => 'Search test case'
  )
```

### Flows, Pages, and Sections

All flows, pages, and sections have shared helper methods

#### wait_until

This method will keep trying until the provided block returns true.
If the provided block returns false or raises an error over and over then an error will be raised at the
end of the timeout.

```ruby
module Application
  module Home
    class SearchFlow < Moose::Flow
      def fill_in_search
        wait_until do
          search_page.search_box_present?
        end
      end
    end
  end
end
```

##### valid options
| Parameter    | Type   | Example                       |
| ------------ | :----- | ----------------------------: |
| timeout      | Number | wait_until(timeout: 30)...    |
| sleep_time   | Number | wait_until(sleep_time: 30)... |


#### maybe_block

This method will keep trying until the provided block returns true.
If the provided block returns false or raises an error over and over then an error will be raised at the
end of the timeout.

```ruby
module Application
  module Home
    class SearchFlow < Moose::Flow
      def fill_in_search
        maybe_block do |maybe|
          maybe.on_success do # optional
            search_page.fill_in_search_box
          end

          maybe.on_failure do # optional
            puts "oh no the search box was never found"
          end

          maybe.loop_over do # required
            search_page.search_box_present?
          end
        end
      end
    end
  end
end
```

##### valid options
| Parameter    | Type   | Example                       |
| ------------ | :----- | ----------------------------: |
| timeout      | Number | maybe_block(timeout: 30)...    |
| sleep_time   | Number | maybe_block(sleep_time: 30)... |


#### Fun Fact: An individual test case can have multiple browsers!
```ruby
Moose.define_test_case do
  browser # will return the latest browser or spin up new browser
  new_browser # spins up a new browser
  new_browser(:browser => :firefox) # spins up a new firefox browser
  new_browser(:headless => true) # spins up a headless browser
  browser(index: 0) # will return first browser

  run_as(OTHER_SUITE_NAME) do |suite_instance, test_case, suite_browser|

  end

  # run block without browser
  run_as(API_SUITE_NAME, :needs_browser => false) do |suite_instance, test_case|

  end
end
```

#### To cut a test case short for whatever reason:
```ruby
Moose.define_test_case do
  ...
  short_circuit! :incomplete, "Message for why here" # possible values [:incomplete, :fail, :pass, :skipped, :pending]

  run_as(OTHER_SUITE_NAME) do |suite_instance, test_case, suite_browser|

  end
  ...
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Potato

![](https://upload.wikimedia.org/wikipedia/commons/4/47/Russet_potato_cultivar_with_sprouts.jpg)

Special thanks to @kiisu-dsalyss for being the Virgin Mooseherder.


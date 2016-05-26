module Moose
  module Assertions
    extend self
    class AssertError < Moose::Error; end

    def default_compare_message(expected, actual)
      "\n|  Expected Value: #{expected}\n|    Actual Value: #{actual}"
    end

    def compare(expected:, actual:, message: default_compare_message(expected, actual))
      unless actual == expected
        raise AssertError, message
      end
      return true
    end

    def assert_present(locator)
      unless locator.available?
        raise AssertError, "FAIL: Expected #{locator.css} to be present"
      end
      return true
    end

    def assert_match(locator, match)
      unless locator.available? && locator.text =~ match
        raise AssertError, "FAIL: Expected #{locator.text} to match #{match}"
      end
      return true
    end
  end
end

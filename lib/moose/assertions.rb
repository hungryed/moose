module Meese
  module Assertions
    class AssertError < Meese::Error; end

    def compare(expected:, actual:)
      expected_value = compare_array[0]
      actual_value = compare_array[1]
      unless actual_value == expected_value
        raise AssertError, "\n|  Expected Value: #{expected}\n|    Actual Value: #{actual}"
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

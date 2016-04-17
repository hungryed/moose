require_relative "../test_status"

module Meese
  module Assertions
    include TestStatus
    extend self


    def compare(compare_array)
      expected_value = compare_array[0]
      actual_value = compare_array[1]
      if actual_value == expected_value
        output = Pass # PASS
      else
        output = Fail
      end # FAIL
      result = "\n|  Expected Value: #{expected_value}\n|    Actual Value: #{actual_value} \n|  Results: #{output}"
      Meese.msg.standard(result)
      result = result.split.last
      if result == Fail
        pause_on_fail
      end
      return result
    end


    def assert(check)
      if check
        Meese.msg.pass('.')
      else
        Meese.msg.fail("FAIL: Expected truthiness, got #{check}")
      end

      check
    end

    def assert_present(locator)
      check = locator.available?

      if check
        Meese.msg.pass('.')
      else
        Meese.msg.fail("FAIL: Expected #{locator.css} to be present")
      end

      check
    end

    def assert_match(locator, match)
      check = !!(locator.available? && locator.text =~ match)

      if check
        Meese.msg.pass('.')
      else
        Meese.msg.fail("FAIL: Expected #{locator.text} to match #{match}")
      end

      check
    end
  end
end

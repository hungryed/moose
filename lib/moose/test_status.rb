module Moose
  module TestStatus
    def self.included(klass)
      klass.extend(ClassMethods)
      klass.include(InstanceMethods)
    end

    module ClassMethods
      def status_method(meth)
        @status_method = meth.to_sym
      end

      def instance_status_method
        @status_method || :result
      end
    end

    module InstanceMethods
      # Possible result values for tests
      FAIL = "FAIL"
      PASS = "PASS"
      INCOMPLETE = "INCOMPLETE"
      PENDING = "PENDING"
      SKIPPED = "SKIPPED"

      def pass_or_result!(result)
        if [FAIL, PASS, INCOMPLETE, PENDING, SKIPPED].include?(result)
          assign_status(result)
        else
          pass!
        end
      end

      def pass!
        assign_status(PASS)
      end

      def fail!
        assign_status(FAIL)
      end

      def mark_as_pending!
        assign_status(PENDING)
      end

      def failed?
        send(self.class.instance_status_method) == FAIL
      end

      def passed?
        send(self.class.instance_status_method) == PASS
      end

      def incomplete?
        send(self.class.instance_status_method) == INCOMPLETE
      end

      def pending?
        send(self.class.instance_status_method) == PENDING
      end

      def skipped?
        send(self.class.instance_status_method) == SKIPPED
      end

      def assign_status(status)
        send("#{self.class.instance_status_method}=", status)
      end
    end
  end
end

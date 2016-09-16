module Moose
  module TestStatus
    POSSIBLE_STATUSES = [:failed, :passed, :incomplete, :pending, :skipped]

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
      POSSIBLE_RESULTS = [FAIL, PASS, INCOMPLETE, PENDING, SKIPPED]

      def pass_or_result!(result)
        if find_result_status(result)
          assign_status(result)
        else
          pass!
        end
      end

      def find_result_status(status)
        POSSIBLE_RESULTS.find { |stat| stat == status.to_s.upcase }
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

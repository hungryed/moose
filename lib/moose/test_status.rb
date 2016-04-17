module Meese
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

      def fail!
        send("#{self.class.instance_status_method}=", FAIL)
      end

      def mark_as_pending!
        send("#{self.class.instance_status_method}=", PENDING)
      end

      def failed?
        send(self.class.instance_status_method) == FAIL
      end

      def passed?
        send(self.class.instance_status_method) == PASS
      end
    end
  end
end

module Spektr
  class Checks
    class BasicAuth < Base
      def run
        check_filter
      end

      def check_filter
        calls = @target.find_calls(:http_basic_authenticate_with)
        calls.each do |call|
          if call.options[:password] && call.options[:password].value.type == :str
            warn! @target, self, call.location, "Basic authentication password stored in source code"
          end
        end
      end
    end
  end
end

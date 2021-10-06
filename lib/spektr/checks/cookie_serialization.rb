module Spektr
  class Checks
    class CookieSerialization < Base
      def run
        calls = @target.find_calls(:cookies_serializer=)
        if calls.any?{ |call| call.receiver.expanded == "Rails.application.config.action_dispatch" }
          warn! @target, self, calls.first.location, "Marshal cookie serialization strategy can lead to remote code execution"
        end
      end
    end
  end
end
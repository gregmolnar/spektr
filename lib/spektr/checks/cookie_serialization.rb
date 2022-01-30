module Spektr
  class Checks
    class CookieSerialization < Base

      def initialize(app, target)
        super
        @name = "Unsafe deserialisation"
        @type = "Insecure Deserialization"
        @targets = ["Spektr::Targets::Base", "Spektr::Targets::Controller"]
      end

      def run
        return unless super
        calls = @target.find_calls(:cookies_serializer=)
        if calls.any?{ |call| call.receiver.expanded == "Rails.application.config.action_dispatch" && call.arguments.first.name == :marshal }
          warn! @target, self, calls.first.location, "Marshal cookie serialization strategy can lead to remote code execution"
        end
      end
    end
  end
end

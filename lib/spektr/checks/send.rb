module Spektr
  class Checks
    class Send < Base
      def initialize(app, target)
        super
        @name = "Dangerous send"
        @type = "Dangerous send"
        @targets = ["Spektr::Targets::Base", "Spektr::Targets::Model", "Spektr::Targets::Controller", "Spektr::Targets::Routes", "Spektr::Targets::View"]
      end

      def run
        return unless super
        [:send, :try, :__send__, :public_send].each do |method|
          @target.find_calls(method).each do |call|
            argument = call.arguments.arguments.first
            if user_input?(argument)
              warn! @target, self, call.location, "User supplied value in send"
            end
          end
        end
      end
    end
  end
end

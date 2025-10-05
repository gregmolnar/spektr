module Spektr
  class Checks
    class DetailedExceptions < Base

      def name

      end

      def initialize(app, target)
        super
        @name = "Information Disclosure"
        @type = "Information Disclosure"
        @targets = ["Spektr::Targets::Base", "Spektr::Targets::Controller"]
      end

      def run
        return unless super
        call = @target.find_calls(:consider_all_requests_local=).last
        if call && call.arguments.arguments.first.type == :true_node
          warn! @target, self, call.location, "Detailed exceptions are enabled in production"
        end
        # TODO: make this better, by verifying that the method body is not empty, etc
        if call = @target.find_method(:show_detailed_exceptions?)
          warn! @target, self, call.location, "Detailed exceptions may be enabled in #{@target.name}"
        end
      end
    end
  end
end

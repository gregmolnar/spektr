module Spektr
  class Checks
    class CreateWith < Base
      def initialize(app, target)
        super
        @name = "Strong parameter bypass (CVE-2014-3514)"
        @type = "Input validation"
        @targets = ["Spektr::Targets::Base", "Spektr::Targets::Controller", "Spektr::Targets::Routes", "Spektr::Targets::View"]
      end

      def run
        return unless super
        if app_version_between?("4.0.0", "4.0.8") || app_version_between?("4.1.0", "4.1.5")
          calls = @target.find_calls(:create_with)
          calls.each do |call|
            call.arguments.each do |argument|
              if user_input?(argument.type, argument.name, argument.ast)
                next if argument.ast.children[1] == :permit
                warn! @target, self, call.location, "create_with is vulnerable to strong params bypass"
              end
            end
          end
        end
      end
    end
  end
end

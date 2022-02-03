module Spektr
  class Checks
    class Evaluation < Base
      def initialize(app, target)
        super
        @name = "Arbitrary code execution"
        @type = "Remote Code Execution"
        @targets = ["Spektr::Targets::Base", "Spektr::Targets::Model", "Spektr::Targets::Controller", "Spektr::Targets::Routes", "Spektr::Targets::View"]
      end

      def run
        return unless super
        [:eval, :instance_eval, :class_eval, :module_eval].each do |name|
          @target.find_calls(name).each do |call|
            call.arguments.each do |argument|
              if user_input?(argument.type, argument.name, argument.ast)
                warn! @target, self, call.location, "User input in eval"
              end
            end
          end
        end
      end
    end
  end
end

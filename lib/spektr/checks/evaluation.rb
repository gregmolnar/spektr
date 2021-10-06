module Spektr
  class Checks
    class Evaluation < Base
      def run
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

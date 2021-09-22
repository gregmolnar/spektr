module Spektr
  class Checks
    class Xss < Base
      # TODO: tests for haml, xml, js
      # TODO: add check for raw calls
      def run
        calls = @target.find_calls(:safe_expr_append=)
        calls.each do |call|
          call.arguments.each do |argument|
            if user_input?(argument.type, argument.name)
              warn! @target, self, call.location, "Cross-Site Scripting: Unescaped #{argument.name}"
            end
            if model_attribute?(argument)
              warn! @target, self, call.location, "Cross-Site Scripting: Unescaped model attribute #{argument.name}"
            end
          end
        end
        calls = @target.find_calls(:html_safe)
        calls.each do |call|
          if user_input?(call.receiver.type, call.receiver.name)
            warn! @target, self, call.location, "Cross-Site Scripting: Unescaped #{call.receiver.name}"
          end
          if model_attribute?(call.receiver)
            warn! @target, self, call.location, "Cross-Site Scripting: Unescaped model attribute #{call.receiver.name}"
          end
        end
      end
    end
  end
end

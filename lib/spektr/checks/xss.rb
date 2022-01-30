module Spektr
  class Checks
    class Xss < Base
      def initialize(app, target)
        super
        @name = "XSS"
        @type = "Cross-Site Scripting"
        @targets = ["Spektr::Targets::Base", "Spektr::Targets::Controller", "Spektr::Targets::View"]
      end

      # TODO: tests for haml, xml, js
      # TODO: add check for raw calls
      def run
        return unless super
        calls = @target.find_calls(:safe_expr_append=)
        calls.concat(@target.find_calls(:raw))
        calls.each do |call|
          call.arguments.each do |argument|
            if user_input?(argument.type, argument.name, argument.ast)
              warn! @target, self, call.location, "Cross-Site Scripting: Unescaped user input"
            end
            if model_attribute?(argument)
              warn! @target, self, call.location, "Cross-Site Scripting: Unescaped model attribute #{argument.name}"
            end
          end
        end
        calls.each do |call|
          call.arguments.each do |argument|
            if user_input?(argument.type, argument.name, argument.ast)
              warn! @target, self, call.location, "Cross-Site Scripting: Unescaped user input"
            end
            if model_attribute?(argument)
              warn! @target, self, call.location, "Cross-Site Scripting: Unescaped model attribute #{argument.name}"
            end
          end
        end
        calls = @target.find_calls(:html_safe)
        calls.each do |call|
          if user_input?(call.receiver.type, call.receiver.name, call.receiver.ast, call.receiver)
            warn! @target, self, call.location, "Cross-Site Scripting: Unescaped user input"
          end
          if model_attribute?(call.receiver)
            warn! @target, self, call.location, "Cross-Site Scripting: Unescaped model attribute #{call.receiver.name}"
          end
        end
      end
    end
  end
end

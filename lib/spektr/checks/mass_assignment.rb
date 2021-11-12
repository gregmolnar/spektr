module Spektr
  class Checks
    class MassAssignment < Base

      # TODO: Make this better
      def initialize(app, target)
        super
        @name = "Mass Assignment"
        @targets = ["Spektr::Targets::Controller"]
      end

      def run
        return unless super
        model_names = @app.models.collect(&:name)
        calls = []
        model_names.each do |receiver|
          [:new, :build, :create].each do |method|
            calls.concat @target.find_calls(method, receiver)
          end
        end
        calls.each do |call|
          argument = call.arguments.first
          if user_input?(argument.type, argument.name)
            # check for permit with arguments
            next if argument.ast.children[1] == :permit && argument.ast.children[2]
            warn! @target, self, call.location, "Mass assignment"
          end
        end
      end
    end
  end
end

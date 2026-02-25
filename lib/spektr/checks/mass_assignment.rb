module Spektr
  class Checks
    class MassAssignment < Base

      # TODO: Make this better
      def initialize(app, target)
        super
        @name = "Mass Assignment"
        @type = "Input Validation"
        @targets = ["Spektr::Targets::Controller"]
      end

      def run
        return unless super
        model_names = @app.models.collect(&:name)
        calls = []
        model_names.each do |receiver|
          [:new, :build, :create].each do |method|
            calls.concat @target.find_calls(method, receiver&.to_sym)
          end
        end
        calls.each do |call|
          argument = call.arguments&.arguments&.first
          next if argument.nil?
          ::Spektr.logger.debug "Mass assignment check at #{call.location.start_line}"
          next unless user_input?(argument)
          if argument.type == :local_variable_read_node
            variable = @target.lvars.find do |n|
              n.name == argument.name
            end
            param = variable.value
          else
            param = argument
          end
          # we check for permit! separately
          next if param.respond_to?(:name) && param.name == :permit!
          # check for permit with arguments
          next if param.respond_to?(:name) && param.name == :permit && param.arguments
          warn! @target, self, call.location, "Mass assignment"
        end
        @target.find_calls(:permit!).each do |call|
          unless call.arguments
            warn! @target, self, call.location, "permit! allows any keys, use it with caution!", :medium
          end
        end
      end
    end
  end
end

module Spektr
  class Checks
    class CommandInjection < Base
      def initialize(app, target)
        super
        @name = "Command Injection"
        @type = "Command Injection"
        @targets = ["Spektr::Targets::Base", "Spektr::Targets::Controller", "Spektr::Targets::Model", "Spektr::Targets::Routes", "Spektr::Targets::View"]
      end

      def run
        return unless super
        # backticks
        @target.interpolated_xstrings.each do |call|
          call.parts.each do |part|
            if user_input?(part)
              warn! @target, self, call.location, "Command injection"
            end
          end
        end

        targets = [:IO, :Open3, :Kernel, :Spawn, :Process, false]
        methods = [:capture2, :capture2e, :capture3, :exec, :pipeline, :pipeline_r,
        :pipeline_rw, :pipeline_start, :pipeline_w, :popen, :popen2, :popen2e,
        :popen3, :spawn, :syscall, :system, :open]
        targets.each do |target|
          methods.each do |method|
            check_calls(@target.find_calls(method, target))
          end
        end
      end

      def check_calls(calls)
        # TODO: might need to exclude tempfile and ActiveStorage::Filename
        return if calls.empty?
        calls.each do |call|
          if call.arguments.is_a?(Prism::ArgumentsNode)
            argument = call.arguments.arguments.first
          else
            argument = call.arguments.first
          end
          next unless argument
          if user_input?(argument) || model_attribute?(argument)
            warn! @target, self, call.location, "Command injection in #{call.name}"
          # TODO: interpolation, but might be safe, we should make this better
          elsif argument.type == :embedded_statements_node
            warn! @target, self, call.location, "Command injection in #{call.name}", :low
          end
        end
      end
    end
  end
end

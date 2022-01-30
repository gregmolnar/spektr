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
        @target.find_xstr.each do |call|
          argument = call.arguments.first
          next unless argument
          if user_input?(argument.type, argument.name, argument.ast, argument)
            warn! @target, self, call.location, "Command injection in #{call.name}"
          end
        end

        targets = ["IO", "Open3", "Kernel", "POSIX::Spawn", "Process", false]
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
        calls.each do |call|
          file_name = call.arguments.first
          next unless file_name
          if user_input?(file_name.type, file_name.name, file_name.ast, file_name)
            warn! @target, self, call.location, "Command injection in #{call.name}"
          # TODO: interpolation, but might be safe, we should make this better
          elsif file_name.type == :dstr
            warn! @target, self, call.location, "Command injection in #{call.name}", :low
          end
        end
      end
    end
  end
end

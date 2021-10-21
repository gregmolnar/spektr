module Spektr
  class Checks
    class CommandInjection < Base
      def run
        # backticks
        check_calls_for_user_input(@target.find_xstr)

        targets = ["IO", "Open3", "Kernel", "POSIX::Spawn", "Process", nil]
        methods = [:capture2, :capture2e, :capture3, :exec, :pipeline, :pipeline_r,
        :pipeline_rw, :pipeline_start, :pipeline_w, :popen, :popen2, :popen2e,
        :popen3, :spawn, :syscall, :system, :open]
        targets.each do |target|
          methods.each do |method|
            check_calls_for_user_input(@target.find_calls(method, target))
          end
        end
      end

      def check_calls_for_user_input(calls)
        calls.each do |call|
          call.arguments.each do |argument|
            # TODO: this might yield a lot of false positives
            if user_input?(argument.type, argument.name, argument.ast)
              warn! @target, self, call.location, "Command injection"
            end
          end
        end
      end
    end
  end
end

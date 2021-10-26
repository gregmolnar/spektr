module Spektr
  class Checks
    class FileAccess < Base
      def run
        targets = ["Dir", "File", "IO", "Kernel", "Net::FTP", "Net::HTTP", "PStore", "Pathname", "Shell"]
        methods = [:[], :chdir, :chroot, :delete, :entries, :foreach, :glob, :install, :lchmod, :lchown, :link, :load, :load_file, :makedirs, :move, :new, :open, :read, :readlines, :rename, :rmdir, :safe_unlink, :symlink, :syscopy, :sysopen, :truncate, :unlink]
        targets.each do |target|
          methods.each do |method|
            check_calls_for_user_input(@target.find_calls(method, target))
          end
        end
      end

      def check_calls_for_user_input(calls)
        calls.each do |call|
          call.arguments.each do |argument|
            if user_input?(argument.type, argument.name, argument.ast)
              warn! @target, self, call.location, "File Access"
            end
          end
        end
      end
    end
  end
end

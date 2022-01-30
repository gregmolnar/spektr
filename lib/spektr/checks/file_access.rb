module Spektr
  class Checks
    class FileAccess < Base

      def name
        "File access"
      end

      def initialize(app, target)
        super
        @name = "File access"
        @type = "Information Disclosure"
        @targets = ["Spektr::Targets::Base", "Spektr::Targets::Controller", "Spektr::Targets::Routes", "Spektr::Targets::View"]
      end

      def run
        return unless super
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
              warn! @target, self, call.location, "#{argument.name} is used for a filename, which enables an attacker to access arbitrary files."
            end
          end
        end
      end
    end
  end
end

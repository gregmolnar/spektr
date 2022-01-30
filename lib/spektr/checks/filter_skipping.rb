module Spektr
  class Checks
    class FilterSkipping < Base
      def initialize(app, target)
        super
        @name = "Default routes filter skipping"
        @type = "Default Routes"
        @targets = ["Spektr::Targets::Routes"]
      end

      def run
        return unless super
        calls = %w{ match get post put delete }.inject([]) do |memo, method|
          memo.concat @target.find_calls(method.to_sym)
          memo
        end
        calls.each do |call|
          if !call.arguments.empty? && (call.arguments.first.name.include?(":action") or call.arguments.first.name.include?("*action"))
            warn! @target, self, call.location, "CVE-2011-2929 Rails versions before 3.0.10 have a vulnerability which allows filters to be bypassed"
          end
        end
      end

      def should_run?
        app_version_between?("3.0.0", "3.0.9")
      end
    end
  end
end

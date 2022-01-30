module Spektr
  class Checks
    class DefaultRoutes < Base
      def initialize(app, target)
        super
        @name = "Dangerous default routes"
        @targets = ["Spektr::Targets::Routes"]
      end

      def run
        return unless super
        @type = "Remote Code Execution"
        check_for_cve_2014_0130
        @type = "Default routes"
        check_for_default_routes
      end

      def check_for_default_routes
        if app_version_between?(3, 4)
          calls = %w{ match get post put delete }.inject([]) do |memo, method|
            memo.concat @target.find_calls(method.to_sym)
            memo
          end
          calls.each do |call|
            if call.arguments.first.name == ":controller(/:action(/:id(.:format)))" or (call.arguments.first.name.include?(":controller") &&  (call.arguments.first.name.include?(":action") or call.arguments.first.name.include?("*action")) )
              warn! @target, self, call.location, "All public methods in controllers are available as actions"
            end

            if call.arguments.first.name.include?(":action") or call.arguments.first.name.include?("*action")
              warn! @target, self, call.location, "All public methods in controllers are available as actions"
            end
          end
        end
      end

      def check_for_cve_2014_0130
        if app_version_between?("2.0.0", "2.3.18") || app_version_between?("3.0.0", "3.2.17") || app_version_between?("4.0.0", "4.0.4") || app_version_between?("4.1.0", "4.1.0")
          warn! @target, self, nil, "#{@app.rails_version} with globbing routes is vulnerable to directory traversal and remote code execution."
        end
      end
    end
  end
end

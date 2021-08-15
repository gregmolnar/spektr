module Spektr
  class Checks
    class ContentTagXss < Base
      def run
        calls = @target.find_calls(:content_tag)
        # https://groups.google.com/d/msg/ruby-security-ann/8B2iV2tPRSE/JkjCJkSoCgAJ
        cve_2016_6316_check(calls)

        calls.each do |call|
          call.arguments.each do |argument|
            if user_input?(argument.type, argument.name) && @app.rails_version < Gem::Version.new("3.0")
              warn! @target, self, call.location, "Unescaped parameter in content_tag"
            end
          end

          if call.options.any?
            call.options.each_value do |option|
              if user_input?(option.key.type, option.key.children.last)
                warn! @target, self, call.location, "Unescaped attribute name in content_tag"
              end
            end
          end
        end
      end

      def cve_2016_6316_check(calls)
        if calls.any? && app_version_between?("3.0.0", "3.2.22.3") || app_version_between?("4.0.0", "4.2.7.0") || app_version_between?("5.0.0", "5.0.0.0")
          warn! @target, self, calls.first.location, "Rails #{@app.rails_version} does not escape double quotes in attribute values"
        end
      end
    end
  end
end
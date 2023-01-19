module Spektr
  class Checks
    class ContentTagXss < Base
      # Checks for unescaped values in `content_tag`
      #
      #    content_tag :tag, body
      #                       ^-- Unescaped in Rails 2.x
      #
      #    content_tag, :tag, body, attribute => value
      #                                ^-- Unescaped in all versions
      # TODO:
      #    content_tag, :tag, body, attribute => value
      #                                            ^
      #                                            |
      #            Escaped by default, can be explicitly escaped
      #            or not by passing in (true|false) as fourth argument
      def initialize(app, target)
        super
        @name = "XSS in content_tag"
        @type = "Cross-Site Scripting"
        @targets = ["Spektr::Targets::Base", "Spektr::Targets::View"]
      end

      def run
        return unless super
        return unless @app.rails_version
        calls = @target.find_calls(:content_tag)
        # https://groups.google.com/d/msg/ruby-security-ann/8B2iV2tPRSE/JkjCJkSoCgAJ
        cve_2016_6316_check(calls)

        calls.each do |call|
          call.arguments.each do |argument|
            if user_input?(argument.type, argument.name, argument.ast) && @app.rails_version < Gem::Version.new("3.0")
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

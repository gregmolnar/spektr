module Spektr
  class Checks
    class DynamicFinders < Base

      def initialize(app, target)
        super
        @name = "SQL Injection by unsafe usage of find_by_*"
        @type = "SQL Injection"
        @targets = ["Spektr::Targets::Base", "Spektr::Targets::Controller", "Spektr::Targets::View"]
      end

      def run
        return unless super
        if app_version_between?("2.0.0", "4.1.99") && @app.has_gem?("mysql")
          @target.find_calls(/^find_by_/).each do |call|
            call.arguments.each do |argument|
              if user_input?(argument.type, argument.name, argument.ast)
                warn! @target, self, call.location, "MySQL integer conversion may cause 0 to match any string"
              end
            end
          end
        end
      end
    end
  end
end

module Spektr
  class Checks
    class BasicAuthTiming < Base

      def initialize(app, target)
        super
        @name = "Timing attack in basic auth (CVE-2015-7576)"
        @type = "Timing attack"
        @targets = ["Spektr::Targets::Controller"]
      end

      def run
        return unless super
        if @target.find_calls(:http_basic_authenticate_with).any?
          warn! @target, self, @target.find_calls(:http_basic_authenticate_with).first.location, "Basic authentication in Rails #{@app.rails_version} is vulnerable to timing attacks."
        end
      end

      def version_affected
        Gem::Version.new("4.2.5")
      end
    end
  end
end

module Spektr
  class Checks
    class Csrf < Base
      def initialize(app, target)
        super
        @name = "CSRF token forgery vulnerability (CVE-2020-8166)"
        @type = "Cross-Site Request Forgery"
        @targets = ["Spektr::Targets::Base"]
      end

      def run
        # disable this
        return false
        return unless super
        cve_2020_8186_check
      end

      def cve_2020_8186_check
        if app_version_between?('0.0.0', '5.2.4.2') || app_version_between?('6.0.0', '6.0.3')
          warn! @target, self, nil, "Rails #{@app.rails_version} has a vulnerability that may allow CSRF token forgery"
        end
      end
    end
  end
end

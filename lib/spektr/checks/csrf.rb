module Spektr
  class Checks
    class Csrf < Base
      def run
        cve_2020_8186_check
      end

      def cve_2020_8186_check(calls)
        if app_version_between?('0.0.0', '5.2.4.2') || app_version_between?('6.0.0', '6.0.3')
          warn! @target, self, calls.first.location, "Rails #{@app.rails_version} has a vulnerability that may allow CSRF token forgery"
        end
      end
    end
  end
end

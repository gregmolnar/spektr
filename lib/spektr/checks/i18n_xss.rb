module Spektr
  class Checks
    class I18nXss < Base

      def initialize(app, target)
        super
        @name = "XSS in i18n (CVE-2013-4491)"
        @type = "Cross-Site Scripting"
        @targets = ["Spektr::Targets::Base"]
      end

      def run
        return unless super
        if app_version_between?("3.0.6", "3.2.15") || app_version_between?("4.0.0", "4.0.1")
          warn! "root", self, nil, "I18n has a Cross-Site Scripting vulnerability (CVE_2013_4491)"
        end
      end
    end
  end
end

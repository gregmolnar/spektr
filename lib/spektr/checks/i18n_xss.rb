module Spektr
  class Checks
    class I18nXss < Base
      def run
        if app_version_between?("3.0.6", "3.2.15") || app_version_between?("4.0.0", "4.0.1")
          warn! "root", self, nil, "I18n Cross-Site Scripting CVE_2013_4491"
        end
      end
    end
  end
end

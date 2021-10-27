module Spektr
  class Checks
    class HeaderDos < Base
      def run
        if app_version_between?("3.0.0", "3.2.15")
          warn! "root", self, nil, "CVE_2013_6414"
        end
      end
    end
  end
end

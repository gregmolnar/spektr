module Spektr
  class Checks
    class HeaderDos < Base

      def initialize(app, target)
        super
        @name = "HTTP MIME type header DoS (CVE-2013-6414)"
        @type = "Denial of Service"
        @targets = ["Spektr::Targets::Base"]
      end

      def run
        return unless super
        if app_version_between?("3.0.0", "3.2.15")
          warn! "root", self, nil, "CVE_2013_6414"
        end
      end
    end
  end
end

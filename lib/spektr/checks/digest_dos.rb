module Spektr
  class Checks
    class DigestDos < Base
      def initialize(app, target)
        super
        @name = "DoS in digest authentication(CVE-2012-3424)"
        @type = "Denial of Service"
        @targets = ["Spektr::Targets::Base", "Spektr::Targets::Controller"]
      end

      def run
        return unless super
        return unless should_run?
        calls = @target.find_calls(:authenticate_or_request_with_http_digest)
        calls.concat(@target.find_calls(:authenticate_with_http_digest))
        if calls.any?
          warn! @target, self, calls.first.location, "Vulnerability in digest authentication CVE-2012-3424"
        else
          warn! "root", self, nil, "Vulnerability in digest authentication CVE-2012-3424"
        end
      end

      def should_run?
        app_version_between?("3.0.0", "3.0.15") || app_version_between?("3.1.0", "3.1.6") || app_version_between?("3.2.0", "3.2.5")
      end
    end
  end
end

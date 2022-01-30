module Spektr
  class Checks
    class JsonEncoding < Base
      def initialize(app, target)
        super
        @name = "XSS by missing JSON encoding"
        @type = "Cross-Site Scripting"
        @targets = ["Spektr::Targets::Base", "Spektr::Targets::Controller", "Spektr::Targets::Routes", "Spektr::Targets::View"]
      end

      def run
        return unless super
        if app_version_between?("4.1.0", "4.1.10") || app_version_between?("4.2.0", "4.2.1")
          if calls = @target.find_calls(:to_json).any? || calls = @target.find_calls(:encode).any?
            warn! @target, self, calls.first.location, "Cross-Site Scripting CVE_2015_3226"
          else
            warn! "root", self, nil, "Cross-Site Scripting CVE_2015_3226"
          end
        end
      end
    end
  end
end

module Spektr
  class Checks
    class JsonParsing < Base
      def initialize(app, target)
        super
        @name = "JSON parsing vulnerability"
        @type = "Remote Code Execution"
        @targets = ["Spektr::Targets::Base"]
      end

      def run
        return unless super
        check_cve_2013_0333
        check_cve_2013_0269
      end

      def check_cve_2013_0333
        return unless app_version_between?("0.0.0", "2.3.15") || app_version_between?("3.0.0", "3.0.19")
        if @app.has_gem?("yajl")
          warn! "root", self, nil, "Remote Code Execution CVE_2013_0333"
        end
        uses_json_gem?
      end

      def uses_json_gem?
        @target.find_calls(:backend=).each do |call|
          if call.receiver.expanded == "ActiveSupport.JSON" && call.arguments.first&.name == :JSONGem
            warn! @target, self, call.location, "Remote Code Execution CVE_2013_0333"
          end
        end
      end

      def check_cve_2013_0269
        ["json", "json_pure"].each do |gem_name|
          if g = @app.gem_specs&.find { |g| g.name == gem_name }
            if version_between?("1.7.0", "1.7.6", g.version)
              warn! "Gemfile", self, nil, "Unsafe Object Creation Vulnerability in the #{g.name} gem"
            end
            if version_between?("0", "1.5.4", g.version) || version_between?("1.6.0", "1.6.7", g.version)
              warn! "Gemfile", self, nil, "Unsafe Object Creation Vulnerability in the  #{g.name} gem"
            end
          end
        end
      end
    end
  end
end

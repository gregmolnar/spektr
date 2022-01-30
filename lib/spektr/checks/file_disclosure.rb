module Spektr
  class Checks
    class FileDisclosure < Base

      def initialize(app, target)
        super
        @name = "File existence disclosure"
        @type = "Information Disclosure"
        @targets = ["Spektr::Targets::Base"]
      end

      def run
        return unless super
        config = @app.production_config.find_calls(:serve_static_assets=).first
        if config && config.arguments.first.type == :true
          warn! "root", self, nil, "File existence disclosure vulnerability"
        end
      end

      def should_run?
        app_version_between?("2.0.0", "2.3.18") || app_version_between?("3.0.0", "3.2.20") || app_version_between?("4.0.0", "4.0.11") || app_version_between?("4.1.0", "4.1.7")
      end
    end
  end
end

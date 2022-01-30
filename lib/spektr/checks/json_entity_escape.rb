module Spektr
  class Checks
    class JsonEntityEscape < Base

      def initialize(app, target)
        super
        @name = "HTML escaping is disabled for JSON output"
        @type = "Cross-Site Scripting"
        @targets = ["Spektr::Targets::Config", "Spektr::Targets::Base"]
      end

      def run
        return unless super
        if @app.production_config
          config = @app.production_config.find_calls(:escape_html_entities_in_json=).first
        end
        if config and config.receiver.expanded == "config.active_support" && config.arguments.first.type == :false
          warn! @app.production_config.path, self, nil, "HTML entities in JSON are not escaped by default"
        end
        ['ActiveSupport', 'ActiveSupport.JSON.Encoding'].each do |receiver|
          calls = @target.find_calls(:escape_html_entities_in_json=, receiver)
          if calls.any?
            warn! @target, self, calls.first.location, "HTML entities in JSON are not escaped by default"
          end
        end
      end
    end
  end
end


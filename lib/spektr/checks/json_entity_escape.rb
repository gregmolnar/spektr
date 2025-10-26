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
        if config and full_receiver(config) == "config.active_support" && config.arguments.arguments.first.type == :false_node
          warn! @app.production_config.path, self, nil, "HTML entities in JSON are not escaped by default"
        end

        if @target.find_calls(:escape_html_entities_in_json=, 'ActiveSupport'.to_sym).any?
          warn! @target, self, calls.first.location, "HTML entities in JSON are not escaped by default"
        end
        calls = @target.find_calls(:escape_html_entities_in_json=, 'JSON::Encoding'.to_sym)
        calls.each do |call|
          if full_receiver(call) == 'ActiveSupport.JSON.Encoding'
            warn! @target, self, calls.first.location, "HTML entities in JSON are not escaped by default"
          end
        end
      end
    end
  end
end

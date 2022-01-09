module Spektr
  class Checks
    class CsrfSetting < Base
      def initialize(app, target)
        super
        @name = "Cross-Site Request Forgery"
        @targets = ["Spektr::Targets::Controller"]
      end

      def run
        return unless super
        enabled = false
        if @target.parent
          parent_controller = @app.controllers.find{|c| c.name == @target.parent }
           enabled = parent_controller && parent_controller.find_calls(:protect_from_forgery).any?
        end

        return if enabled && @target.find_calls(:skip_forgery_protection).none?

        if @target.find_calls(:protect_from_forgery).none? || (enabled && @target.find_calls(:skip_forgery_protection).any?)
          warn! @target, self, nil, "protect_from_forgery should be enabled"
        end
        if @target.find_calls(:skip_forgery_protection).any?
          warn! @target, self, nil, "protect_from_forgery should be enabled"
        end
      end
    end
  end
end

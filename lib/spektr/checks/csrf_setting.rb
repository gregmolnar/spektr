module Spektr
  class Checks
    class CsrfSetting < Base
      def run
        enabled = false
        if @target.parent
          parent_controller = @app.controllers.find{|c| c.name == @target.parent }
           enabled = parent_controller.find_calls(:protect_from_forgery).any?
        end
        return if enabled && @target.find_calls(:skip_forgery_protection).none?
        if @target.find_calls(:protect_from_forgery).none? || (enabled && @target.find_calls(:skip_forgery_protection).any?)
          warn! @target, self, nil, "Cross-Site Request Forgery should be enabld"
        end
      end
    end
  end
end

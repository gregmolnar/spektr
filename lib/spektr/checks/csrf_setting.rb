module Spektr
  class Checks
    class CsrfSetting < Base
      def initialize(app, target)
        super
        @name = 'Cross-Site Request Forgery'
        @type = 'Cross-Site Request Forgery'
        @targets = ['Spektr::Targets::Controller']
      end

      def run
        return unless super
        return if @target.concern?

        enabled = false
        target = @target
        while target
          parent_controller = target.find_parent(@app.controllers)
          enabled = parent_controller && parent_controller.find_calls(:protect_from_forgery).any?
          break if enabled || parent_controller.nil?

          target = parent_controller
        end
        return if enabled && @target.find_calls(:skip_forgery_protection).none?

        if @target.find_calls(:protect_from_forgery).none? || (enabled && @target.find_calls(:skip_forgery_protection).any?)
          warn! @target, self, nil, 'protect_from_forgery should be enabled'
        end
        if @target.find_calls(:skip_forgery_protection).any?
          warn! @target, self, nil, 'protect_from_forgery should be enabled'
        end
      end
    end
  end
end

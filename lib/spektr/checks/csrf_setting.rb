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

        target = @target
        return if @target.find_calls(:skip_forgery_protection).none?

        skip = @target.find_calls(:skip_forgery_protection).last
        return if skip && skip.arguments && skip.arguments.arguments.first.elements.map(&:key).map(&:unescaped).intersection(%w[only except]).any?

        warn! @target, self, nil, 'protect_from_forgery should be enabled'
      end
    end
  end
end

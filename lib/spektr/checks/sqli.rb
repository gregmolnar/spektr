module Spektr
  class Checks
    class Sqli < Base
      def initialize(app, target)
        super
        @name = "SQL Injection"
        @name = "SQL Injection"
        @targets = ["Spektr::Targets::Base", "Spektr::Targets::Controller", "Spektr::Targets::Model"]
      end

      def run
        return unless super

        [
          :average, :count, :maximum, :minimum, :sum, :exists?,
          :find_by, :find_by!, :find_or_create_by, :find_or_create_by!,
          :find_or_initialize_by, :from, :group, :having, :join, :lock,
          :where, :not, :select, :rewhere, :reselect, :update_all

        ].each do |m|
          @target.find_calls(m).each do |call|
            check_argument(call.arguments.first, m, call)
          end
        end
        [:calculate].each do |m|
          @target.find_calls(m).each do |call|
            check_argument(call.arguments[1], m, call)
          end
        end

        [:delete_by, :destroy_by].each do |m|
          @target.find_calls(m).each do |call|
            if call.arguments.first
              check_argument(call.arguments.first, m, call)
            end
            call.options.values.each do |option|
              check_argument(@target.ast_to_exp(option.key), m, call)
              check_argument(@target.ast_to_exp(option.value), m, call)
            end
          end
        end
      end

      def check_argument(argument, method, call)
        return if argument.nil?
        if user_input?(argument.type, argument.name, argument.ast, argument)
          warn! @target, self, call.location, "Possible SQL Injection at #{method}"
        end
      end
    end
  end
end

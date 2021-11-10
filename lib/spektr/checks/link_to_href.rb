module Spektr
  class Checks
    class LinkToHref < Base

      def initialize(app, target)
        super
        @name = "XSS in href param of link_to"
        @targets = ["Spektr::Targets::Base", "Spektr::Targets::Controller", "Spektr::Targets::View"]
      end

      # TODO: check for user supplied model attributes too
      def run
        return unless super
        block_locations = []
        @target.find_calls_with_block(:link_to).each do |call|
          block_locations << call.location
          if user_input? call.arguments.first.type, call.arguments.first.name, call.arguments.first.ast
            warn! @target, self, call.location, "Cross-Site Scripting: Unsafe user supplied value in link_to"
          end
        end

        @target.find_calls(:link_to).each do |call|
          next if block_locations.include? call.location
          if user_input? call.arguments[1].type, call.arguments[1].name, call.arguments[1].ast
            warn! @target, self, call.location, "Cross-Site Scripting: Unsafe user supplied value in link_to"
          end
        end
      end
    end
  end
end


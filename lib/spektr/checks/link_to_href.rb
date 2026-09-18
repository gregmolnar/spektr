module Spektr
  class Checks
    class LinkToHref < Base
      # Route helpers build the href themselves and escape any interpolated
      # values, so user input reaching one is not an XSS sink.
      ROUTE_HELPER = /_url$|_path$/

      def initialize(app, target)
        super
        @name = "XSS in href param of link_to"
        @type = "Cross-Site Scripting"
        @targets = ["Spektr::Targets::Base", "Spektr::Targets::Controller", "Spektr::Targets::View"]
      end

      # TODO: check for user supplied model attributes too
      def run
        return unless super
        block_locations = []
        @target.find_calls_with_block(:link_to).each do |call|
          block_locations << call.location
          href = call.arguments.arguments.first
          next unless href
          ::Spektr.logger.debug "#{@target.path}  #{call.location.start_line} #{href.inspect}"
          next if route_helper?(href)
          if user_input? href
            warn! @target, self, call.location, "Cross-Site Scripting: Unsafe user supplied value in link_to"
          end
        end

        @target.find_calls(:link_to).each do |call|
          next if block_locations.include? call.location
          next unless call.arguments
          href = call.arguments.arguments[1]
          ::Spektr.logger.debug "#{@target.path}  #{call.location.start_line} #{href.inspect}"
          next unless href
          next if route_helper?(href)
          if user_input? href
            warn! @target, self, call.location, "Cross-Site Scripting: Unsafe user supplied value in link_to"
          end
        end
      end

      private

      def route_helper?(node)
        node.respond_to?(:name) && node.name.to_s =~ ROUTE_HELPER
      end
    end
  end
end

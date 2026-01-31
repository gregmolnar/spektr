module Spektr
  class Checks
    class LinkToHref < Base
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
          next unless call.arguments.arguments.first
          ::Spektr.logger.debug "#{@target.path}  #{call.location.start_line} #{call.arguments.arguments.first.inspect}"
          if user_input? call.arguments.arguments.first
            warn! @target, self, call.location, "Cross-Site Scripting: Unsafe user supplied value in link_to"
          end
        end

        @target.find_calls(:link_to).each do |call|
          next if block_locations.include? call.location
          next unless call.arguments
          ::Spektr.logger.debug "#{@target.path}  #{call.location.start_line} #{call.arguments.arguments[1].inspect}"
          next unless call.arguments.arguments[1]
          name = call.arguments.arguments[1].name
          next if name && name =~ /_url$|_path$/
          if user_input? call.arguments.arguments[1]
            warn! @target, self, call.location, "Cross-Site Scripting: Unsafe user supplied value in link_to"
          end
        end
      end
    end
  end
end

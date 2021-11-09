module Spektr
  class Checks
    class LinkTo < Base
      def run
        return unless app_version_between?("2.0.0", "2.9.9")
        @target.find_calls(:link_to).each do |call|
          next if call.arguments.first.nil? || call.arguments.first.type == :hash
        end
      end
    end
  end
end


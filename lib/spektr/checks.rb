module Spektr
  class Checks

    def self.load
      Checks.constants.map do |c|
        Checks.const_get(c)if Checks.const_get(c).is_a?(Class)
      end
    end

    def warn(target, check, line_number)
    end
  end
end

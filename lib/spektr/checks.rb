module Spektr
  class Checks
    def self.load(only = false)
      Checks.constants.select do |c|
        Checks.const_get(c).is_a?(Class) && (!only || only && only.to_s == c.to_s)
      end.map { |c| Checks.const_get(c) }
    end
  end
end

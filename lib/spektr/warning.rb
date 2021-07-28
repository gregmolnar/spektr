module Spektr
  class Warning
    attr_accessor :message
    def initialize(target, check, location, message)
      @target = target
      @check = check
      @location = location
      @message = message
    end
  end
end

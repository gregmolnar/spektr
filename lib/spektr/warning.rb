module Spektr
  class Warning
    attr_accessor :target, :check, :location, :message
    def initialize(target, check, location, message)
      @target = target
      @check = check
      @location = location
      @message = message
    end

    def full_message
      if @location
        "#{message} at line #{@location.line} of #{@target.path}"
      else
        "#{message}"
      end
    end
  end
end

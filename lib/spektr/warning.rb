module Spektr
  class Warning
    attr_accessor :path, :check, :location, :message, :confidence
    def initialize(path, check, location, message, confidence = :high)
      @path = path
      @check = check
      @location = location
      @message = message
      @confidence = confidence
    end

    def full_message
      if @location
        "#{message} at line #{@location.line} of #{@path}"
      else
        "#{message}"
      end
    end
  end
end

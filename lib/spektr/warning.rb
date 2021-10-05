module Spektr
  class Warning
    attr_accessor :path, :check, :location, :message
    def initialize(path, check, location, message)
      @path = path
      @check = check
      @location = location
      @message = message
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

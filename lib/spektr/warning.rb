module Spektr
  class Warning
    attr_accessor :path, :full_path, :check, :location, :message, :confidence, :line
    def initialize(path, full_path, check, location, message, confidence = :high)
      @path = path
      @check = check
      @location = location
      @message = message
      @confidence = confidence
      if full_path && @location && File.exist?(full_path)
        @line = IO.readlines(full_path)[@location.line - 1].strip
      end
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

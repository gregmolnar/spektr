module RailsScan
  class Checks::BasicAuth

    def initialize(controller)
      @controller = controller
    end

    def run
      if check_filter
        return true
      else
        return false
      end
    end

    def check_filter
      calls = @controller.find_calls(:http_basic_authenticate_with)
      calls.each do |call|
        return false if call.options[:password] && call.options[:password].type == :str
      end
    end
  end
end

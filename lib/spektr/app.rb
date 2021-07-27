module Spektr
  class App
    attr_accessor :root, :controllers, :checks

    def initialize(checks)
      @root = "./"
      @checks = checks
    end

    def load
      @controllers = controller_paths.map do |path|
        Controller.new(File.read(path))
      end
    end

    def controller_paths
      @controller_paths ||= find_files("app/**/controllers")
    end

    def model_paths
      @model_paths ||= find_files("app/**/models")
    end

    def view_paths
      @view_paths ||= find_files("app/**/views")
    end

    def find_files(pattern, extensions = ".rb")
      Dir.glob(File.join(@root, pattern, "**", "*#{extensions}"))
    end
  end
end

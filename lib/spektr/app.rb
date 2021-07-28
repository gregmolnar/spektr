module Spektr
  class App
    attr_accessor :root, :checks, :controllers, :models, :lib_files

    def initialize(checks:, root: "./")
      @root = root
      @checks = checks
    end

    def load
      loaded_files = []
      @controllers = controller_paths.map do |path|
        Targets::Controller.new(path, File.read(path))
        loaded_files << path
      end
      puts "#{@controllers.size} controllers loaded\n"

      @models = model_paths.map do |path|
        Targets::Base.new(path, File.read(path))
        loaded_files << path
      end
      puts "#{@models.size} models loaded\n"

      @lib_files = find_files("app/**/").map do |path|
        next if loaded_files.include?(path)
        Targets::Base.new(path, File.read(path))
      end
      puts "#{@lib_files.size} libs loaded\n"
    end

    def scan

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

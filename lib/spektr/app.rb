module Spektr
  class App
    attr_accessor :root, :checks, :controllers, :models, :views, :lib_files, :warnings, :rails_version

    def initialize(checks:, root: "./")
      @root = root
      @checks = checks
      @warnings = []
    end

    def load
      puts "Rails version: #{rails_version}"
      loaded_files = []
      @controllers = controller_paths.map do |path|
        loaded_files << path
        Targets::Controller.new(path, File.read(path))
      end
      puts "#{@controllers.size} controllers loaded\n"

      @models = model_paths.map do |path|
        loaded_files << path
        Targets::Base.new(path, File.read(path))
      end
      puts "#{@models.size} models loaded\n"

      @views = view_paths.map do |path|
        loaded_files << path
        Targets::View.new(path, File.read(path))
      end
      puts "#{@views.size} views loaded\n"

      @lib_files = find_files("app/**/").map do |path|
        next if loaded_files.include?(path)
        Targets::Base.new(path, File.read(path))
      end
      puts "#{@lib_files.size} libs loaded\n"
    end

    def scan!
      puts "Scanning...."
      @checks.each do |check|
        @controllers.each do |controller|
          check.new(self, controller).run
        end
        @views.each do |view|
          check.new(self, view).run
        end
      end
    end

    def controller_paths
      @controller_paths ||= find_files("app/**/controllers")
    end

    def model_paths
      @model_paths ||= find_files("app/**/models")
    end

    def view_paths
      @view_paths ||= find_files("app", "{#{%w[html.erb html.haml rhtml js.erb html.slim].join(",")}}")
    end

    def find_files(path, extensions = "rb")
      Dir.glob(File.join(@root, path, "**", "*.#{extensions}"))
    end

    def gem_specs
      @gem_specs ||= Bundler::LockfileParser.new(Bundler.read_file("#{@root}/Gemfile.lock")).specs
    end

    def rails_version
      @rails_version ||= gem_specs.find{ |spec| spec.name == "rails" }&.version
    end
  end
end

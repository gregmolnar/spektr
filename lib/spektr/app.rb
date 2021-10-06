module Spektr
  class App
    attr_accessor :root, :checks, :controllers, :models, :views, :lib_files, :routes, :warnings, :rails_version, :production_config, :gem_specs

    def initialize(checks:, root: "./")
      @root = root
      @checks = checks
      @warnings = []
    end

    def load
      puts "Rails version: #{rails_version}"
      loaded_files = []

      config_path = File.join(@root, "config", "environments", "production.rb")
      @production_config = Targets::Base.new(config_path, File.read(config_path))

      @initializers = initializer_paths.map do |path|
        loaded_files << path
        Targets::Base.new(path, File.read(path))
      end
      puts "#{@initializers.size} initializers loaded\n"

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

      @routes = [File.join(@root, "config", "routes.rb")].map do |path|
        loaded_files << path
        Targets::Routes.new(path, File.read(path))
      end
      puts "#{@routes.size} routes loaded\n"

      @lib_files = find_files("app/**/").map do |path|
        next if loaded_files.include?(path)
        Targets::Base.new(path, File.read(path))
      end.reject(&:nil?)
      puts "#{@lib_files.size} libs loaded\n"
    end

    def scan!
      puts "Scanning...."
      @checks.each do |check|
        @controllers.each do |controller|
          check.new(self, controller).run
        end if @controllers
        @views.each do |view|
          check.new(self, view).run
        end if @views
        @models.each do |view|
          check.new(self, view).run
        end if @models
        @routes.each do |view|
          check.new(self, view).run
        end if @routes
        check.new(self, @production_config).run
      end
    end

    def initializer_paths
      @initializer_paths ||= find_files("config/initializers")
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

    def has_gem?(name)
      gem_specs.any?{ |spec| spec.name == name }
    end

    def rails_version
      @rails_version ||= Gem::Version.new(gem_specs.find{ |spec| spec.name == "rails" }&.version)
    end
  end
end

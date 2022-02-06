module Spektr
  class App
    attr_accessor :root, :checks, :controllers, :models, :views, :lib_files, :routes, :warnings, :rails_version, :production_config, :gem_specs

    def initialize(checks:, root: "./")
      @root = root
      @checks = checks
      @controllers = []
      @models = []
      @warnings = []
      @json_output = {
        app: {},
        advisories: [],
      }
    end

    def load
      loaded_files = []

      config_path = File.join(@root, "config", "environments", "production.rb")
      @production_config = Targets::Config.new(config_path, File.read(config_path)) if File.exist?(config_path)

      @initializers = initializer_paths.map do |path|
        loaded_files << path
        Targets::Base.new(path, File.read(path))
      end
      @controllers = controller_paths.map do |path|
        loaded_files << path
        Targets::Controller.new(path, File.read(path))
      end
      @models = model_paths.map do |path|
        loaded_files << path
        Targets::Model.new(path, File.read(path))
      end
      @views = view_paths.map do |path|
        loaded_files << path
        Targets::View.new(path, File.read(path))
      end
      @routes = [File.join(@root, "config", "routes.rb")].map do |path|
        next unless File.exist? path
        loaded_files << path
        Targets::Routes.new(path, File.read(path))
      end.reject(&:nil?)
      # todo load non-app lib too
      @lib_files = find_files("lib").map do |path|
        next if loaded_files.include?(path)
        Targets::Base.new(path, File.read(path))
      end.reject(&:nil?)
      self
    end

    def scan!
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
        @initializers.each do |i|
          check.new(self, i).run
        end if @initializers
        @lib_files.each do |i|
          check.new(self, i).run
        end if @lib_files

        check.new(self, @production_config).run if @production_config
      end
      self
    end

    def report(format = "terminal")
      @json_output[:app][:rails_version] = @rails_version
      @json_output[:app][:initializers] = @initializers.size
      @json_output[:app][:controllers] = @controllers.size
      @json_output[:app][:models] = @models.size
      @json_output[:app][:views] = @views.size
      @json_output[:app][:routes] = @routes.size
      @json_output[:app][:lib_files] = @lib_files.size

      @warnings.each do |warning|
        @json_output[:advisories] << {
          name: warning.check.name,
          description: warning.message,
          path: warning.path,
          location: warning.location&.line,
          line: warning.line,
        }
      end

      @json_output[:summary] = []

      @json_output[:advisories].group_by { |a| a[:name] }.each do |n, i|
        @json_output[:summary] << {
          n => i.size,
        }
      end
      case format
      when "json"
        @json_output
      when "terminal"
        "Hold my beer"
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
      return unless File.exists? "#{@root}/Gemfile.lock"
      @gem_specs ||= Bundler::LockfileParser.new(Bundler.read_file("#{@root}/Gemfile.lock")).specs
    end

    def has_gem?(name)
      return false unless gem_specs
      gem_specs.any? { |spec| spec.name == name }
    end

    def rails_version
      return unless gem_specs
      @rails_version ||= Gem::Version.new(gem_specs.find { |spec| spec.name == "rails" }&.version)
    end
  end
end

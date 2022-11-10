module Spektr
  class App
    attr_accessor :root, :checks, :initializers, :controllers, :models, :views, :lib_files, :routes, :warnings, :rails_version,
                  :production_config, :gem_specs, :ruby_version

    def self.parser
      @@parser ||= Parser::CurrentRuby
    end

    def initialize(checks:, ignore: [], root: './')
      @root = root
      @checks = checks
      @controllers = []
      @models = []
      @warnings = []
      @json_output = {
        app: {},
        advisories: []
      }
      @ignore = ignore
      @ruby_version = '2.7.1'
      version_file = File.join(root, '.ruby-version')
      @ruby_version = File.read(version_file).lines.first if File.exist?(version_file)
      case @ruby_version
      when /^2\.0\./
        require 'parser/ruby20'
        @@parser = Parser::Ruby20
      when /^2\.1\./
        require 'parser/ruby21'
        @@parser = Parser::Ruby21
      when /^2\.2\./
        require 'parser/ruby22'
        @@parser = Parser::Ruby22
      when /^2\.3/
        require 'parser/ruby23'
        @@parser = Parser::Ruby23
      when /^2\.4\./
        require 'parser/ruby24'
        @@parser = Parser::Ruby24
      when /^2\.5\./
        require 'parser/ruby25'
        @@parser = Parser::Ruby25
      when /^2\.6\./
        require 'parser/ruby26'
        @@parser = Parser::Ruby26
      when /^2\.7\./
        require 'parser/ruby27'
        @@parser = Parser::Ruby27
      when /^3\.0\./
        require 'parser/ruby30'
        @@parser = Parser::Ruby30
      when /^3\.1\./
        require 'parser/ruby31'
        @@parser = Parser::Ruby31
      when /^3\.2\./
        require 'parser/ruby32'
        @@parser = Parser::Ruby32
      else
        @@parser = Parser::CurrentRuby
      end
    end

    def load
      loaded_files = []

      config_path = File.join(@root, 'config', 'environments', 'production.rb')
      if File.exist?(config_path)
        @production_config = Targets::Config.new(config_path,
                                                 File.read(config_path, encoding: 'utf-8'))
      end

      @initializers = initializer_paths.map do |path|
        loaded_files << path
        Targets::Base.new(path, File.read(path))
      end
      @controllers = controller_paths.map do |path|
        loaded_files << path
        Targets::Controller.new(path, File.read(path, encoding: 'utf-8'))
      end
      @models = model_paths.map do |path|
        loaded_files << path
        Targets::Model.new(path, File.read(path, encoding: 'utf-8'))
      end
      @views = view_paths.map do |path|
        loaded_files << path
        Targets::View.new(path, File.read(path, encoding: 'utf-8'))
      end
      @routes = [File.join(@root, 'config', 'routes.rb')].map do |path|
        next unless File.exist? path

        loaded_files << path
        Targets::Routes.new(path, File.read(path, encoding: 'utf-8'))
      end.reject(&:nil?)
      # TODO: load non-app lib too
      @lib_files = find_files('lib').map do |path|
        next if loaded_files.include?(path)
        begin
          Targets::Base.new(path, File.read(path, encoding: 'utf-8'))
        rescue Parser::SyntaxError => e
          ::Spektr.logger.debug "Couldn't parse #{path}: #{e.message}"
          nil
        end
      end.reject(&:nil?)
      self
    end

    def scan!
      @checks.each do |check|
        if @controllers
          @controllers.each do |controller|
            check.new(self, controller).run
          end
        end
        if @views
          @views.each do |view|
            check.new(self, view).run
          end
        end
        if @models
          @models.each do |view|
            check.new(self, view).run
          end
        end
        if @routes
          @routes.each do |view|
            check.new(self, view).run
          end
        end
        if @initializers
          @initializers.each do |i|
            check.new(self, i).run
          end
        end
        if @lib_files
          @lib_files.each do |i|
            check.new(self, i).run
          end
        end

        check.new(self, @production_config).run if @production_config
      end
      self
    end

    def report
      @json_output[:app][:rails_version] = @rails_version
      @json_output[:app][:initializers] = @initializers.size
      @json_output[:app][:controllers] = @controllers.size
      @json_output[:app][:models] = @models.size
      @json_output[:app][:views] = @views.size
      @json_output[:app][:routes] = @routes.size
      @json_output[:app][:lib_files] = @lib_files.size

      @warnings.each do |warning|
        next if @ignore.include?(warning.fingerprint)

        @json_output[:advisories] << {
          name: warning.check.name,
          description: warning.message,
          path: warning.path,
          location: warning.location&.line,
          line: warning.line,
          check: warning.check.class.name,
          fingerprint: warning.fingerprint
        }
      end

      @json_output[:summary] = []
      @json_output[:checks] = @checks.collect(&:name)

      @json_output[:advisories].group_by { |a| a[:name] }.each do |n, i|
        @json_output[:summary] << {
          n => i.size
        }
      end
      @json_output
    end

    def initializer_paths
      @initializer_paths ||= find_files('config/initializers')
    end

    def controller_paths
      @controller_paths ||= find_files('app/**/controllers')
    end

    def model_paths
      @model_paths ||= find_files('app/**/models')
    end

    def view_paths
      @view_paths ||= find_files('app', "{#{%w[html.erb html.haml rhtml js.erb html.slim].join(',')}}")
    end

    def find_files(path, extensions = 'rb')
      Dir.glob(File.join(@root, path, '**', "*.#{extensions}"))
    end

    def gem_specs
      return unless File.exist? "#{@root}/Gemfile.lock"

      @gem_specs ||= Bundler::LockfileParser.new(Bundler.read_file("#{@root}/Gemfile.lock")).specs
    end

    def has_gem?(name)
      return false unless gem_specs

      gem_specs.any? { |spec| spec.name == name }
    end

    def rails_version
      return unless gem_specs

      @rails_version ||= Gem::Version.new(gem_specs.find { |spec| spec.name == 'rails' }&.version)
    end
  end
end

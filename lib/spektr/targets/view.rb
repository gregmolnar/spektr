module Spektr
  module Targets
    class View < Base
      TEMPLATE_EXTENSIONS = /.*\.(erb|rhtml|haml|slim|herb)$/
      attr_accessor :view_path

      def initialize(path, content)
        super
        @calls = []
        Spektr.logger.debug "loading #{path}"
        @view_path = nil
        @path = path
        if match_data = path.match(%r{views/(.+?)\.})
          @view_path = match_data[1]
        end
        @ast = Prism.parse(source(content))
        @ast.value.accept(self)
        @name = @view_path
      end

      def source(content)
        type = @path.match(TEMPLATE_EXTENSIONS)[1].to_sym
        case type
        when :erb, :rhtml, :herb
          Erubi.new(content, trim_mode: '-').src
          # Herb.extract_ruby(content)
        when :haml
          Haml::Engine.new(content).precompiled
        when :slim
          erb = Slim::ERBConverter.new.call(content)
          Erubi.new(erb, trim_mode: '-').src
        end
      end
    end
  end
end

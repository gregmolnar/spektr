module Spektr
  module Targets
    class View < Base
      TEMPLATE_EXTENSIONS = /.*\.(erb|rhtml|haml|slim)$/
      attr_accessor :view_path

      def initialize(path, content)
        Spektr.logger.debug "loading #{path}"
        @view_path = nil
        @path = path
        if match_data = path.match(%r{views/(.+?)\.})
          @view_path = match_data[1]
        end
        begin
          @ast = Spektr::App.parser.parse(source(content))
        rescue Parser::SyntaxError => e
          @ast = Spektr::App.parser.parse('')
          ::Spektr.logger.error "Parser::SyntaxError when parsing #{@view_path}: #{e.message}"
        end
        @name = @view_path # @ast.children.first.children.last.to_s
      end

      def source(content)
        type = @path.match(TEMPLATE_EXTENSIONS)[1].to_sym
        case type
        when :erb, :rhtml
          Erubi.new(content, trim_mode: '-').src
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

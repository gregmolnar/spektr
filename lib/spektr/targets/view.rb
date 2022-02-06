module Spektr
  module Targets
    class View < Base
      TEMPLATE_EXTENSIONS = /.*\.(erb|rhtml|haml)$/
      attr_accessor :view_path

      def initialize(path, content)
        @view_path = nil
        @path = path
        if match_data = path.match(/views\/(.+?)\./)
          @view_path = match_data[1]
        end
        begin
          @ast = Parser::CurrentRuby.parse(source(content))
        rescue Parser::SyntaxError => e
          @ast = Parser::CurrentRuby.parse("")
          ::Spektr.logger.error "Parser::SyntaxError when parsing #{@view_path}: #{e.message}"
        end
        @name = @view_path #@ast.children.first.children.last.to_s
      end

      def source(content)
        type = @path.match(TEMPLATE_EXTENSIONS)[1].to_sym
        case type
        when :erb, :rhtml
          Erubi.new(content, trim_mode: "-").src
        when :haml
          Haml::Engine.new(content).precompiled
        end
      end
    end
  end
end

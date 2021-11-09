module Spektr
  module Targets
    class View < Base
      TEMPLATE_EXTENSIONS = /.*\.(erb|rhtml)$/
      attr_accessor :view_path

      def initialize(path, content)
        @path = path
        if match_data = path.match(/views\/(.+?)\./)
          @view_path = match_data[1]
        end
        @ast = Parser::CurrentRuby.parse(source(content))
        @name = @ast.children.first.children.last.to_s
      end

      def source(content)
        type = @path.match(TEMPLATE_EXTENSIONS)[1].to_sym
        case type
        when :erb, :rhtml
          Erubi.new(content, trim_mode: '-').src
        end
      end
    end
  end
end

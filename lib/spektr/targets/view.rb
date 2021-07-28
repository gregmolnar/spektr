module Spektr
  module Targets
    class View < Base
      TEMPLATE_EXTENSIONS = /.*\.(erb|rhtml)$/
      def initialize(path, content)
        @path = path
        @ast = Parser::CurrentRuby.parse(source(content))
        @name = @ast.children.first.children.last.to_s
      end

      def source(content)
        type = @path.match(TEMPLATE_EXTENSIONS)[1].to_sym
        case type
        when :erb, :rhtml
          ERB.new(content, nil, '-').src
        end
      end
    end
  end
end

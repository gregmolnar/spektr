module Spektr
  class Call
    attr_accessor :name, :options

    def initialize(ast)
      @name = ast.children[1]
      @options = {}
      ast.children[2..].each do |option|
        if option.type == :hash
          option.children.each do |pair|
            @options[pair.children[0].children[0]] = pair.children[1]
          end
        end
      end
    end
  end
end

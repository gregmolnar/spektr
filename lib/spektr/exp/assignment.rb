module Spektr
  module Exp
    module Assignment
      def user_input?
        if ast.children[1].type == :send
          _send = Send.new(ast.children[1])
          name = if _send.receiver.is_a?(Parser::AST::Node) && _send.receiver.type == :send
            Send.new(_send.receiver).name
          else
            _send.receiver.to_sym
          end
          if [:params, :cookies, :request].include? name
            return true
          end
        end
        false
      end
    end
  end
end

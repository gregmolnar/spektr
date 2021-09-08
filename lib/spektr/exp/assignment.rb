module Spektr
  module Exp
    module Assignment
      def user_input?
        if ast.children[1].type == :send
          _send = Send.new(ast.children[1])
          name = if _send.receiver && _send.receiver.type == :send
            _send.receiver.name
          else
            nil
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

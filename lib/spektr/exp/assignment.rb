module Spektr
  module Exp
    module Assignment
      def user_input?
        if ast.children[1].type == :send
          _send = Send.new(ast.children[1])
          if _send.receiver.type == :send
            receiver =  Send.new(_send.receiver)
            if [:params, :cookies, :request].include? receiver.name
              return true
            end
          end
        end
        false
      end
    end
  end
end

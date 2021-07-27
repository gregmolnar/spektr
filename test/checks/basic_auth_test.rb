require "test_helper"

class BasicAuthTest < Minitest::Test

  def setup
  end

  def test_it_fails_with_plaintext_password
    code = <<-CODE
      class ApplicationController
        http_basic_authenticate_with name: "dhh", password: "secret", except: :index
      end
    CODE

    ast = Parser::CurrentRuby.parse(code)
    controller = Spektr::Controller.new("ApplicationController", ast)
    check = Spektr::Checks::BasicAuth.new(controller)
    assert_equal false, check.run
  end
end

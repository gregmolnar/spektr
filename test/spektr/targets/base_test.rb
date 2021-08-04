require "test_helper"

class BaseTest < Minitest::Test
  def setup
    code = <<-CODE
      class ApplicationController
        http_basic_authenticate_with name: "dhh", password: "secret", except: :index

        def index
        end

        def show
        end

        private
          def authenticate!
          end
      end
    CODE
    @target = Spektr::Targets::Base.new("application_controller.rb", code)
  end

  def test_it_finds_call
    calls = @target.find_calls :http_basic_authenticate_with
    refute_empty calls
    assert_equal 1, calls.size
  end

  def test_it_finds_methods
    assert_equal 3, @target.find_methods(ast: @target.ast).size
  end

  def test_it_finds_public_methods
    assert_equal 2, @target.find_methods(ast: @target.ast, type: :public).size
  end
end

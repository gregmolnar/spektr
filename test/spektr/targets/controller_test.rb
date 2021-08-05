require "test_helper"

class ControllerTest < Minitest::Test
  def setup
    code = <<-CODE
      class ApplicationController
        http_basic_authenticate_with name: "dhh", password: "secret", except: :index

        def index
        end

        def show
        end

        def update
          render :edit
        end

        private
          def authenticate!
          end
      end
    CODE

    @controller = Spektr::Targets::Controller.new("application_controller.rb", code)
  end

  def test_it_sets_name
    assert_equal "ApplicationController", @controller.name
  end

  def test_it_finds_call
    calls = @controller.find_calls :http_basic_authenticate_with
    refute_empty calls
    assert_equal 1, calls.size
  end

  def test_it_registers_actions
    assert_equal 3, @controller.actions.size
  end
end

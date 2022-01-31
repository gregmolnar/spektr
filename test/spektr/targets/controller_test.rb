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
    code = <<-CODE
    require "foobar"
    class ApplicationController
    end
    CODE
    controller = Spektr::Targets::Controller.new("application_controller.rb", code)
    assert_equal "ApplicationController", controller.name
    code = <<-CODE
    module Admin
      module Schools
        class PupilsController
        end
      end
    end
    CODE
    controller = Spektr::Targets::Controller.new("pupils_controller.rb", code)
    assert_equal "Admin::Schools::PupilsController", controller.name
    code = <<-CODE
    module Admin::Schools
      class PupilsController
        def index
        end
      end
    end
    CODE
    controller = Spektr::Targets::Controller.new("pupils_controller.rb", code)
    assert_equal "Admin::Schools::PupilsController", controller.name
    code = <<-CODE
    module Admin
      class Schools::PupilsController
        def index
        end
      end
    end
    CODE
    controller = Spektr::Targets::Controller.new("pupils_controller.rb", code)
    assert_equal "Admin::Schools::PupilsController", controller.name
  end

  def test_it_sets_parent
    code = <<-CODE
    class ApplicationController
    end
    CODE
    controller = Spektr::Targets::Controller.new("application_controller.rb", code)
    assert_nil controller.parent
    code = <<-CODE
    class PostsController < ApplicationController
    end
    CODE
    controller = Spektr::Targets::Controller.new("application_controller.rb", code)
    assert_equal "ApplicationController", controller.parent
    code = <<-CODE
    class SessionsController < Devise::SessionsController
    end
    CODE
    controller = Spektr::Targets::Controller.new("application_controller.rb", code)
    assert_equal "Devise::SessionsController", controller.parent
    code = <<-CODE
    module Admin
      class PostsController < ApplicationController
        def index
        end
      end
    end
    CODE
    controller = Spektr::Targets::Controller.new("application_controller.rb", code)
    assert_equal "ApplicationController", controller.parent
  end

  def test_it_sets_template
    code = <<-CODE
    class PostsController
      def index
      end
    end
    CODE
    controller = Spektr::Targets::Controller.new("application_controller.rb", code)
    assert_equal "posts/index", controller.actions.first.template
    code = <<-CODE
    module Admin
      class PostsController < ApplicationController
        def index
        end
      end
    end
    CODE
    controller = Spektr::Targets::Controller.new("application_controller.rb", code)
    assert_equal "admin/posts/index", controller.actions.first.template
    code = <<-CODE
    class Admin::PostsController < ApplicationController
      def index
      end
    end
    CODE
    controller = Spektr::Targets::Controller.new("application_controller.rb", code)
    assert_equal "admin/posts/index", controller.actions.first.template
    code = <<-CODE
    class SessionsController < Devise::SessionsController
      def index
      end
    end
    CODE
    controller = Spektr::Targets::Controller.new("application_controller.rb", code)
    assert_equal "devise/sessions/index", controller.actions.first.template
  end

  def test_it_finds_call
    calls = @controller.find_calls :http_basic_authenticate_with
    refute_empty calls
    assert_equal 1, calls.size
  end

  def test_it_registers_actions
    assert_equal 3, @controller.actions.size
    assert_empty @controller.actions.first.body
    refute_empty @controller.actions[2].body
  end
end

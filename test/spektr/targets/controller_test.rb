require 'test_helper'

class ControllerTest < Minitest::Test
  def test_it_sets_name
    code = <<-CODE
    require "foobar"
    class ApplicationController
    end
    CODE
    controller = Spektr::Targets::Controller.new('application_controller.rb', code)
    assert_equal 'ApplicationController', controller.name
    code = <<-CODE
    module Admin
      module Schools
        class PupilsController
        end
      end
    end
    CODE
    controller = Spektr::Targets::Controller.new('pupils_controller.rb', code)
    assert_equal 'Admin::Schools::PupilsController', controller.name
    code = <<-CODE
    module Admin::Schools
      class PupilsController
        def index
        end
      end
    end
    CODE
    controller = Spektr::Targets::Controller.new('pupils_controller.rb', code)
    assert_equal 'Admin::Schools::PupilsController', controller.name
    code = <<-CODE
    module Admin
      class Schools::PupilsController
        def index
        end
      end
    end
    CODE
    controller = Spektr::Targets::Controller.new('pupils_controller.rb', code)
    assert_equal 'Admin::Schools::PupilsController', controller.name
  end

  def test_it_sets_parent
    code = <<-CODE
    class ApplicationController
    end
    CODE
    controller = Spektr::Targets::Controller.new('application_controller.rb', code)
    assert_equal '', controller.parent

    code = <<-CODE
    class PostsController < ApplicationController
    end
    CODE
    controller = Spektr::Targets::Controller.new('application_controller.rb', code)
    assert_equal 'ApplicationController', controller.parent

    code = <<-CODE
    class SessionsController < Devise::SessionsController
    end
    CODE
    controller = Spektr::Targets::Controller.new('application_controller.rb', code)
    assert_equal 'Devise::SessionsController', controller.parent

    code = <<-CODE
    module Admin
      class PostsController < ApplicationController
        def index
        end
      end
    end
    CODE
    controller = Spektr::Targets::Controller.new('admin/posts_controller.rb', code)
    assert_equal 'ApplicationController', controller.parent

    code = <<-CODE
    module Admin
      class PostsController < Admin::ApplicationController
        def index
        end
      end
    end
    CODE
    controller = Spektr::Targets::Controller.new('admin/posts_controller.rb', code)
    assert_equal 'Admin::ApplicationController', controller.parent

    code = <<-CODE
    module Admin
      module Settings
        class CampaignsController < Admin::Settings::BaseController
        end
      end
    end
    CODE
    controller = Spektr::Targets::Controller.new('admin/settings/campaigns_controller.rb', code)
    assert_equal 'Admin::Settings::BaseController', controller.parent

    code = <<-CODE
    module Api
      module V0
        class OrganizationsController < ApiController
        end
      end
    end
    CODE
    controller = Spektr::Targets::Controller.new('api/v0/organisations_controller.rb', code)
    assert_equal 'Api::V0::ApiController', controller.processor.parent_name_with_modules

    code = <<-CODE
    module Admin
      class ProfileFieldsController < Admin::ApplicationController
      end
    end
    CODE
    controller = Spektr::Targets::Controller.new('admin/profile_controller.rb', code)
    assert_equal 'Admin::ApplicationController', controller.processor.parent_name_with_modules
  end

  def test_it_sets_template
    code = <<-CODE
    class PostsController
      def index
      end
    end
    CODE
    controller = Spektr::Targets::Controller.new('application_controller.rb', code)
    assert_equal 'posts/index', controller.actions.first.template
    code = <<-CODE
    module Admin
      class PostsController < ApplicationController
        def index
        end
      end
    end
    CODE
    controller = Spektr::Targets::Controller.new('application_controller.rb', code)
    assert_equal 'admin/posts/index', controller.actions.first.template
    code = <<-CODE
    class Admin::PostsController < ApplicationController
      def index
      end
    end
    CODE
    controller = Spektr::Targets::Controller.new('application_controller.rb', code)
    assert_equal 'admin/posts/index', controller.actions.first.template
    code = <<-CODE
    class SessionsController < Devise::SessionsController
      def index
      end
    end
    CODE
    controller = Spektr::Targets::Controller.new('application_controller.rb', code)
    assert_equal 'devise/sessions/index', controller.actions.first.template
  end

  def setup_application_controller
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

    @controller = Spektr::Targets::Controller.new('application_controller.rb', code)
  end

  def test_it_finds_call
    setup_application_controller
    calls = @controller.find_calls :http_basic_authenticate_with
    refute_empty calls
    assert_equal 1, calls.size
  end

  def test_it_registers_actions
    setup_application_controller
    assert_equal 3, @controller.actions.size
    assert_empty @controller.actions.first.body
    refute_empty @controller.actions[2].body
  end
end

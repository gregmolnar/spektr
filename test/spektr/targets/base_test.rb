require 'test_helper'

class BaseTest < Minitest::Test
  def setup_application_controller
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
    @target = Spektr::Targets::Base.new('application_controller.rb', code)
  end


  def test_it_sets_name
    application_controller = <<-CODE
      class ApplicationController
        protect_from_forgery
      end
    CODE

    admin_application_controller = <<-CODE
      module Admin
        class ApplicationController < ApplicationController
        end
      end
    CODE

    admin_controller = <<-CODE
      module Admin
        class AdminController < Admin::ApplicationController
        end
      end
    CODE

    admin_posts_controller = <<-CODE
      module Admin
        class PostsController < AdminController
        end
      end
    CODE
    application_controller = Spektr::Targets::Controller.new('application_controller.rb', application_controller)
    assert_equal "ApplicationController", application_controller.name
    admin_application_controller = Spektr::Targets::Controller.new('admin/application_controller.rb', admin_application_controller)
    assert_equal "Admin::ApplicationController", admin_application_controller.name
    admin_controller = Spektr::Targets::Controller.new('admin_controller.rb', admin_controller)
    assert_equal "Admin::AdminController", admin_controller.name
    admin_posts_controller = Spektr::Targets::Controller.new('posts_controller.rb', admin_posts_controller)
    assert_equal "Admin::PostsController", admin_posts_controller.name
  end

  def test_it_finds_call
    setup_application_controller
    calls = @target.find_calls :http_basic_authenticate_with
    refute_empty calls
    assert_equal 1, calls.size
  end

  def test_it_finds_call_for_receiver
    setup_application_controller
    code = <<-CODE
      Kernel.exec("ls")
      POSIX::Spawn.exec("ls")
    CODE
    target = Spektr::Targets::Base.new('application_controller.rb', code)
    assert_equal 1, target.find_calls(:exec, :Kernel).size
    assert_equal 1, target.find_calls(:exec, "POSIX::Spawn".to_sym).size

  end

  def test_it_handles_root_scope
    code = <<-CODE
      ::Kernel.exec("ls")
    CODE
    target = Spektr::Targets::Base.new('application_controller.rb', code)
    assert_equal 1, target.find_calls(:exec, :Kernel).size
  end

  def test_it_finds_methods
    setup_application_controller
    assert_equal 3, @target.method_definitions.size
  end

  def test_it_finds_public_methods
    setup_application_controller
    assert_equal 2, @target.public_methods.size
  end

  def test_it_finds_call_with_block
    setup_application_controller
    code = <<-CODE
      [1].each do |i|
        link_to "inside block", i
      end
      link_to "test" do
        "hey"
      end
    CODE
    target = Spektr::Targets::Base.new('application_controller.rb', code)
    assert_equal 1, target.find_calls_with_block(:link_to).size
  end

  def test_it_finds_parent
    code = <<-CODE
      class Model < Parent
      end
    CODE
    target = Spektr::Targets::Base.new('model.rb', code)
    assert_equal 'Parent', target.parent
  end

  def test_it_finds_namespaced_parent
    code = <<-CODE
      class Model < Namespace::Parent
      end
    CODE
    target = Spektr::Targets::Base.new('model.rb', code)
    assert_equal 'Namespace::Parent', target.parent
  end

  def test_it_finds_module_parent
    code = <<-CODE
      module Namespace
        class Model < Parent
        end
      end
    CODE
    target = Spektr::Targets::Base.new('namespace/model.rb', code)
    assert_equal 'Namespace::Parent', target.parent
  end

  def test_it_finds_parent_with_same_name_in_module
    code = <<-CODE
      class Model < Namespace::Model
        def foo
          Bar.new
        end
      end
    CODE
    target = Spektr::Targets::Base.new('namespace/model.rb', code)
    assert_equal 'Namespace::Model', target.parent
  end

  def test_it_finds_struct_parent
    code = <<-CODE
      class Result < Struct.new(:status_code, :message)
      end
    CODE
    target = Spektr::Targets::Base.new('cat.rb', code)
    assert_equal 'Struct', target.parent
  end
end

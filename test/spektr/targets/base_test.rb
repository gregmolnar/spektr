require "test_helper"

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
    @target = Spektr::Targets::Base.new("application_controller.rb", code)
  end

  def test_it_finds_call
    setup_application_controller
    calls = @target.find_calls :http_basic_authenticate_with
    refute_empty calls
    assert_equal 1, calls.size
  end

  def test_it_finds_methods
    setup_application_controller
    assert_equal 3, @target.find_methods(ast: @target.ast).size
  end

  def test_it_finds_public_methods
    setup_application_controller
    assert_equal 2, @target.find_methods(ast: @target.ast, type: :public).size
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
    target = Spektr::Targets::Base.new("application_controller.rb", code)
    assert_equal 1, target.find_calls_with_block(:link_to).size
  end

  def test_it_finds_parent
    code = <<-CODE
      class Model < Parent
      end
    CODE
    target = Spektr::Targets::Base.new("model.rb", code)
    assert_equal 'Parent', target.parent
  end

  def test_it_finds_namespaced_parent
    code = <<-CODE
      class Model < Namespace::Parent
      end
    CODE
    target = Spektr::Targets::Base.new("model.rb", code)
    assert_equal 'Namespace::Parent', target.parent
  end

  def test_it_finds_module_parent
    code = <<-CODE
      module Namespace
        class Model < Parent
        end
      end
    CODE
    target = Spektr::Targets::Base.new("namespace/model.rb", code)
    assert_equal 'Namespace::Parent', target.processor.parent_name_with_modules
  end

  def test_it_finds_parent_with_same_name_in_module
    code = <<-CODE
      class Model < Namespace::Model
        def foo
          Bar.new
        end
      end
    CODE
    target = Spektr::Targets::Base.new("namespace/model.rb", code)
    assert_equal 'Namespace::Model', target.processor.parent_name_with_modules

  end

  def test_it_finds_struct_parent
    code = <<-CODE
      class Result < Struct.new(:status_code, :message)
      end
    CODE
    target = Spektr::Targets::Base.new("cat.rb", code)
    assert_equal 'Struct', target.parent
  end
end

require "test_helper"

class MassAssignmentTest < Minitest::Test
  def setup
    model = <<-CODE
      class Post
      end
    CODE
    @app = Spektr::App.new(checks: [Spektr::Checks::MassAssignment])
    model = Spektr::Targets::Model.new("post.rb", model)
    @app.models << model
  end

  def test_it_fails_with_params_assignment
    code = <<-CODE
      class BlogController
        def create
          post = Post.new(params[:post])
        end
      end
    CODE
    controller = Spektr::Targets::Controller.new("blog_controller.rb", code)
    check = Spektr::Checks::MassAssignment.new(@app, controller)
    check.run
    assert_equal 1, @app.warnings.size
  end

  def test_it_doesnt_fail_with_permit
    code = <<-CODE
      class BlogController
        def create
          post = Post.new(params[:post].permit(:title, :body))
        end
      end
    CODE
    controller = Spektr::Targets::Controller.new("blog_controller.rb", code)
    check = Spektr::Checks::MassAssignment.new(@app, controller)
    check.run
    assert_equal 0, @app.warnings.size
  end

  def test_it_fails_with_permit_bang
    code = <<-CODE
      class BlogController
        def create
          post = Post.new(params[:post].permit!)
        end
      end
    CODE
    controller = Spektr::Targets::Controller.new("blog_controller.rb", code)
    check = Spektr::Checks::MassAssignment.new(@app, controller)
    check.run
    assert_equal 1, @app.warnings.size
  end
end

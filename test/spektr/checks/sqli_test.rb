require "test_helper"

class SqliTest < Minitest::Test
  def setup
    @app = Spektr::App.new(checks: [Spektr::Checks::Sqli])
  end

  def test_it_fails_with_dangerous_methods_and_user_input
    code = <<-CODE
      class BlogController
        def index
          Post.count(:id)
          Post.average(params[:column])
          Post.count(params[:column])
          Post.maximum(params[:column])
          Post.minimum(params[:column])
          Post.sum(params[:column])

          Post.calculate(:sum, :total)
          Post.calculate(:sum, params[:cookie])

          Post.delete_by(id: 1)
          Post.delete_by(params[:key] => 1)
          Post.delete_by(id: params[:key])
          Post.delete_by("id=\#{params[:id]}")

          Post.exists?(1)
          Post.exists?(params[:id])

          Post.find_by(params[:id])
          Post.find_by!(params[:id])
          Post.find_or_create_by(params[:id])
          Post.find_or_create_by!(params[:id])
          Post.find_or_initialize_by(params[:id])

          Post.from(params[:from])
          Post.group(params[:group])
          Post.having(params[:having])
          Post.join(params[:join])
          Post.lock(params[:lock])

          Post.where(params[:q])
          Post.where("id = \#{params[:q]}")
          Post.where.not(params[:q])
          Post.rewhere(params[:q])

          Post.select(params[:field])
          Post.reselect(params[:field])

          Post.update_all(params[:q])

        end
      end
    CODE
    controller = Spektr::Targets::Controller.new("blog_controller.rb", code)
    check = Spektr::Checks::Sqli.new(@app, controller)
    check.run
    assert_equal 27, @app.warnings.size
  end
end

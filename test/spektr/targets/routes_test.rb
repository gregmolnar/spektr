require "test_helper"

class RoutesTest < Minitest::Test
  def setup
    code = <<-CODE
      Rails3::Application.routes.draw do
        resources :products
      end
    CODE

    @routes = Spektr::Targets::Routes.new("routes.rb", code)
  end

end

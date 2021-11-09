require "test_helper"

class LinkToHrefTest < Minitest::Test
  def test_it_fails_with_a_user_supplied_value_with_block
    code = <<-CODE
      <%=
      link_to params[:blog] do
        "hello"
      end
      %>
    CODE
    app = Spektr::App.new(checks: [Spektr::Checks::LinkToHref])
    view = Spektr::Targets::View.new("index.html.erb", code)
    check = Spektr::Checks::LinkToHref.new(app, view)
    check.run
    assert_equal 1, app.warnings.size
  end

  def test_it_fails_with_a_user_supplied_value
    code = <<-CODE
      <%= link_to "Hello", params[:blog] %>
    CODE
    app = Spektr::App.new(checks: [Spektr::Checks::LinkToHref])
    view = Spektr::Targets::View.new("index.html.erb", code)
    check = Spektr::Checks::LinkToHref.new(app, view)
    check.run
    assert_equal 1, app.warnings.size
  end

end

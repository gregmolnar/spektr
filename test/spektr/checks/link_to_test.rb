require "test_helper"

class LinkToTest < Minitest::Test
  def test_does_not_fail_with_hash_argument_nor_no_argument
    code = <<-CODE
      <%= link_to() %>
      <%= link_to({"foo" => "bar"}, foobar_url) %>
    CODE
    app = Spektr::App.new(checks: [Spektr::Checks::LinkTo])
    view = Spektr::Targets::View.new("index.html.erb", code)
    check = Spektr::Checks::LinkTo.new(app, view)
    check.run
    assert_equal 0, app.warnings.size
  end
end

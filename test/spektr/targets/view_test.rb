require "test_helper"

class ViewTest < Minitest::Test
  def setup
    code = <<-CODE
      <%= content_tag :div, 'foo' %>
    CODE

    @view = Spektr::Targets::View.new("index.html.erb", code)
  end

  def test_it_finds_call
    calls = @view.find_calls :content_tag
    refute_empty calls
    assert_equal 1, calls.size
  end
end

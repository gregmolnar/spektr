require "test_helper"
describe Spektr::Exp::Ivasign do
  describe "with options" do
    before do
      code = <<-CODE

      CODE

    end

    it "is from secure source" do
      ivasign = Spektr::Exp::Ivasign.new(Parser::CurrentRuby.parse('@foobar = "barfoo"'))
      refute ivasign.user_input?
    end

    it "is from params" do
      ivasign = Spektr::Exp::Ivasign.new(Parser::CurrentRuby.parse('@foobar = params["barfoo"]'))
      assert ivasign.user_input?
    end
  end
end

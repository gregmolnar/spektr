require "test_helper"
describe Spektr::Exp::Definition do
  describe "with options" do
    before do
      code = <<-CODE
        class ApplicationController
          def index
          end

          def show
            foobar = "barfoo"
            render :show
          end

          private
            def has_argument(foobar)
            end
        end
      CODE

      target = Spektr::Targets::Base.new("", code)
      @definitions = target.find_methods(ast: target.ast).map{ |ast| Spektr::Exp::Definition.new(ast)}
    end

    it "sets name" do
      assert_equal :index, @definitions.first.name
      assert_empty @definitions.first.arguments
    end

    it "sets arguments" do
      assert_empty @definitions.first.arguments
      assert_equal [:foobar], @definitions.last.arguments
    end

    it "sets body" do
      assert_empty @definitions.first.body
      assert_equal 2, @definitions[1].body.size
    end

  end
end

module Spektr
  class Checks
    class Deserialize < Base

      def initialize(app, target)
        super
        @name = "Unsafe object deserialization"
        @type = "Insecure Deserialization"
        @targets = ["Spektr::Targets::Base", "Spektr::Targets::Controller", "Spektr::Targets::Routes", "Spektr::Targets::View"]
      end

      def run
        return unless super
        check_csv
        check_yaml
        check_marshal
        check_oj
      end

      def check_csv
        check_method(:load, "CSV")
      end

      # TODO: handle safe yaml
      def check_yaml
        [:load_documents, :load_stream, :parse_documents, :parse_stream].each do |method|
          check_method(method, "YAML")
        end
      end

      def check_marshal
        [:load, :restore].each do |method|
          check_method(method, "Marshal")
        end
      end

      def check_oj
        check_method(:object_load, "Oj")
        safe_default = false
        safe_default = true if @target.find_calls(:mimic_JSON, "Oj").any?
        call = @target.find_calls(:default_options=, "Oj").last
        safe_default = true if call && call.options[:mode]&.value != :object
        unless safe_default
          check_method(:load, "Oj")
        end
      end

      def check_method(method, receiver)
        calls = @target.find_calls(method, receiver)
        calls.each do |call|
          argument = call.arguments.first
          if argument.ast.type == :send && argument.ast.children.last.children.first.is_a?(Parser::AST::Node)
            argument = Exp::Argument.new(argument.ast.children.last.children.first)
          end
          if user_input?(argument.type, argument.name, argument.ast)
            warn! @target, self, call.location, "#{receiver}.#{method} is called with user supplied value"
          end
        end
      end
    end
  end
end

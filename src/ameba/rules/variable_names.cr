module Ameba::Rules
  # A rule that enforces variable names to be in underscored case.
  #
  # For example, these variable names are considered valid:
  #
  # ```
  # class Greeting
  #   @@default_greeting = "Hello world"
  #
  #   def initialize(@custom_greeting = nil)
  #   end
  #
  #   def print_greeting
  #     greeting = @custom_greeting || @@default_greeting
  #     puts greeting
  #   end
  # end
  # ```
  #
  # And these are invalid method names:
  #
  # ```
  # myBadNamedVar = 1
  # wrong_Name = 2
  # ```
  #
  struct VariableNames < Rule
    def test(source)
      [
        AST::VarVisitor,
        AST::InstanceVarVisitor,
        AST::ClassVarVisitor,
      ].each &.new(self, source)
    end

    private def check_node(source, node)
      return if (expected = node.name.underscore) == node.name

      source.error self, node.location.try &.line_number,
        "Var name should be underscore-cased: #{expected}, not #{node.name}"
    end

    def test(source, node : Crystal::Var)
      check_node source, node
    end

    def test(source, node : Crystal::InstanceVar)
      check_node source, node
    end

    def test(source, node : Crystal::ClassVar)
      check_node source, node
    end
  end
end

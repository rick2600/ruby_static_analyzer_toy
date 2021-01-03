class RubyVM::AbstractSyntaxTree::Node
  #attr_accessor :parent, :block

  def find_all(node_types)
    @find_all_param = node_types
    @find_all_result = []

    visitor = AST::Visitor.new(
      callback_enter: method(:do_find_all)
    )
    visitor.visit(self)
    @find_all_result
  end

  def do_find_all(node)
    @find_all_result << node if @find_all_param.include?(node.type)
  end

end

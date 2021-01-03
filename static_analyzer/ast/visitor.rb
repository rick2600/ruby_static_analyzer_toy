module AST
  class Visitor
    def initialize(params = {})
      @callback_enter = params[:callback_enter]
      @callback_leave = params[:callback_leave]
    end

    def exec_callback_enter(node)
      unless @callback_enter.nil?
        @callback_enter.call(node)
      end
    end

    def exec_callback_leave(node)
      unless @callback_leave.nil?
        @callback_leave.call(node)
      end
    end

    def visit(node)
      @visited = []
      do_visit(node)
      @visited = nil
    end

    def do_visit(node)
      return if @visited.include?(node)
      @visited << node
      if node.is_a?(RubyVM::AbstractSyntaxTree::Node)
        exec_callback_enter(node)
        node.children.each do |child|
          do_visit(child)
        end
        exec_callback_leave(node)
      end
    end

    #def visit_generic(node)
    #  node.children.each do |child|
    #    visit(child)
    #  end
    #end

  end
end

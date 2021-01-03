require_relative 'basic_block'

module CFG
  class Builder
    def initialize(function)
      @function = function
      @current_block = BasicBlock.new(@function.block_id)
      @entry_block = @current_block
      @visited = []
      @loop_stack = []
      @after_loop_stack = []
    end

    def build(ast)
      visit(ast)
      remove_empty_blocks
      @entry_block
    end

    def remove_empty_blocks
      @empty_blocks = []
      find_empty_blocks

      @empty_blocks.reverse.each do |empty_block|
        empty_block.parents.each do |parent|
          parent.children.delete(empty_block)
          #parent.children += empty_block.children
          empty_block.children.each do |child_of_empty|
            child_of_empty.parents.delete(empty_block)
            parent.add_child(child_of_empty)
          end
          parent.children.uniq!
        end
      end
    end

    def find_empty_blocks
      @visited = []
      do_find_empty_blocks(@entry_block)
    end

    def do_find_empty_blocks(block)
      return if @visited.include?(block)
      @visited << block
      @empty_blocks << block if block.stmts.empty?

      block.children.each do |child|
        do_find_empty_blocks(child)
      end
    end


    def visit(node)
      #p node.type
      if node.is_a?(RubyVM::AbstractSyntaxTree::Node)
        visit_method = "visit_#{node.type}"
        if respond_to?(visit_method)
          send(visit_method, node)
        else
          #puts "not found #{node.type}"
          visit_generic(node)
        end
      end
    end

    def visit_generic(node)
      @current_block.add_statement(node)
      new_block = BasicBlock.new(@function.block_id)
      @current_block.add_child(new_block)
      @current_block = new_block
    end

    def visit_SCOPE(node)
      visit(node.children[2])
    end

    def visit_WHILE(node)
      @current_block.add_statement(node.children[0])

      while_block = @current_block
      body_block = BasicBlock.new(@function.block_id)
      after_while_block = BasicBlock.new(@function.block_id)

      @loop_stack.push(while_block)
      @after_loop_stack.push(after_while_block)

      if node.children[1].type == :BLOCK and node.children[1].children[0] == nil
        while_block.add_child(after_while_block)
        while_block.add_child(while_block)
      else
        while_block.add_child(body_block)
        while_block.add_child(after_while_block)

        @current_block = body_block
        visit(node.children[1])
        @current_block.add_child(while_block)
      end

      @current_block = after_while_block
      @loop_stack.pop
      @after_loop_stack.pop
    end

    def visit_NEXT(node)
      @current_block.add_statement(node)
      @current_block.add_child(@loop_stack.last)
    end

    def visit_BREAK(node)
      @current_block.add_statement(node)
      @current_block.add_child(@after_loop_stack.last)
    end


    def visit_IF(node)
      @current_block.add_statement(node.children[0])
      if_block = @current_block

      after_if_block = BasicBlock.new(@function.block_id)
      true_block = BasicBlock.new(@function.block_id)
      else_block = BasicBlock.new(@function.block_id)

      # if without true block
      if node.children[1].type == :BEGIN and node.children[1].children[0] == nil
        if_block.add_child(after_if_block)
      else
        true_block.cond = :true
        if_block.add_child(true_block)
        @current_block = true_block
        visit(node.children[1])

        if @current_block.stmts.first.nil?
          @current_block.add_child(after_if_block)
        else
          if ![:NEXT, :BREAK].include?(@current_block.stmts.first.type)
            @current_block.add_child(after_if_block)
          end
        end
      end

      if node.children[2].nil?
        if_block.add_child(after_if_block)
      else
        else_block.cond = :false
        if_block.add_child(else_block)
        @current_block = else_block
        visit(node.children[2])

        if @current_block.stmts.first.nil?
          @current_block.add_child(after_if_block)
        else
          if ![:NEXT, :BREAK].include?(@current_block.stmts.first.type)
            @current_block.add_child(after_if_block)
          end
        end
      end

      @current_block = after_if_block
    end

    def visit_ITER(node)
      @current_block.add_statement(node.children[0])
      iter_block = @current_block
      body_block =  BasicBlock.new(@function.block_id)
      after_iter_block = BasicBlock.new(@function.block_id)

      @loop_stack.push(iter_block)
      @after_loop_stack.push(after_iter_block)

      iter_block.add_child(body_block)
      iter_block.add_child(after_iter_block)

      @current_block = body_block

      visit(node.children[1])
      @current_block.add_child(iter_block)
      @current_block = after_iter_block

      @loop_stack.pop
      @after_loop_stack.pop
    end


    def visit_BLOCK(node)
      node.children.each do |child|
        visit(child)
      end
    end

  end

end





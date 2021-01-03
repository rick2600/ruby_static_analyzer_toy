module CFG
  class BasicBlock
    attr_accessor :stmts, :parents, :children, :cond, :block_id
    attr_accessor :gen, :in, :out

    def initialize(block_id)
      @block_id   = block_id
      @stmts      = []
      @parents    = []
      @children   = []
      @cond       = :any
      @gen        = []
      @in         = []
      @out        = []
    end

    def add_statement(node)
      @stmts << node
      #node.block = self
    end

    def add_parent(parent)
      @parents << parent
      parent.children << self
    end

    def add_child(child)
      @children << child
      child.parents << self
    end
  end
end

module DataFlow
  module ReachingDefinitionAnalysis

    def reach_definition_analysis
      init_blocks(@root)
      @change = true
      while @change
        @change = false
        calculate_in_out(@root)
      end
    end

    def init_blocks(root)
      @visited = []
      do_init_block(root)
    end

    def do_init_block(block)
      return if @visited.include?(block)
      @visited << block
      calculate_gen(block)
      block.children.each {|child| do_init_block(child) }
    end

    def calculate_in_out(root)
      @visited = []
      do_calculate_in_out(root)
    end

    def do_calculate_in_out(block)
      return if @visited.include?(block)
      @visited << block

      block.parents.each {|parent| block.in += parent.out }
      block.in.uniq!
      kill = calculate_kill(block)

      old_out = block.out.dup
      block.out = block.gen + (block.in - kill)
      @change = true if block.out != old_out

      debug = false
      if debug
        puts '==== DEBUG ===='
        p "block: B_#{block.block_id}"
        p "gen:   #{block.gen.map{|d| d.def_id}}"
        p "kill:  #{kill.map{|d| d.def_id}}"
        p "in:    #{block.in.map{|d| d.def_id}}"
        p "out:   #{block.out.map{|d| d.def_id}}"
      end

      block.children.each do |child|
        do_calculate_in_out(child)
      end
    end

    def calculate_kill(block)
      kill = []
      vars_set = block.gen.map {|d| d.var}
      block.in.each {|d| kill << d if vars_set.include?(d.var) }
      kill.uniq
    end

    def calculate_gen(block)
      ast_node = block.stmts.first
      ast_node.find_all([:LASGN]).each do |ast_node|
        def_id = new_def_id
        def_gen = Definition.new(def_id, ast_node.children[0], ast_node.first_lineno)
        block.gen << def_gen
        block.out << def_gen
      end
    end
  end
end

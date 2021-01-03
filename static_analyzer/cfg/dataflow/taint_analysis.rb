module DataFlow
  module TaintAnalysis

    def taint_analysis(config)
      propagate_from_sources(config[:sources])
      find_tainted_uses(config)
    end


    def compute_taint_propagation(config)
      propagate_from_sources(config[:sources])
    end

    def find_dangerous_fcall(config)
      find_tainted_uses(config)
    end


    def propagate_from_sources(sources)
      @tainted_defs = Set.new
      @taint_sources = sources
      @change = true
      while @change
        @change = false
        taint_propagation(@root)
      end
    end

    def find_tainted_uses(config)
      @visited = []
      visit_cfg(@root, config)
    end

    def visit_cfg(block, config)
      return if @visited.include?(block)
      @visited << block

      block.stmts.first.find_all([:FCALL]).each do |fcall|
        analyze_fcall(block, config, fcall)
      end

      block.children.each do |child|
        visit_cfg(child, config)
      end
    end

    def trace(block, fcall, param_name, status)
      current_def = status[:def]
      lines = []
      while true
        break if current_def.nil?
        lines << current_def.line
        current_def = current_def.tainted_by.first
      end
      lines.reverse!
      lines << fcall.first_lineno
      lines
    end

    def report_use(block, fcall, param_name, status)
      locations = trace(block, fcall, param_name, status)
      @function.vulnerabilities << {trace: locations, function: fcall.children[0]}
    end

    def report_use2(block, fcall, param_name, status)
      puts "[*] Tainted var reaches #{fcall.children[0]}() call"
      locations = trace(block, fcall, param_name, status)
      out = "Trace:\n"
      locations.each_with_index do |line, i|
        pad = ' '*(i*2)
        out << "#{pad} Location: #{@function.path}:#{line}\n"
      end
      out << "\n"
      puts out
    end


    def analyze_fcall(block, config, fcall)
      fname = fcall.children[0]
      if config[:sinks].include?(fname)
        dangerous_params = config[:sinks][fname][:dangerous_params]
        fcall_params = fcall.children[1].find_all([:ARRAY]).first
        fcall_params.children.each_with_index do |param_node, param_idx|
          next if param_node.nil?
          status = taint_status(block, param_node)
          if status[:tainted] and dangerous_params.include?(param_idx)
            report_use(block, fcall, param_node.children[0], status)
          end
        end
      end
    end

    def taint_propagation(root)
      @visited = []
      do_taint_propagation(root)
    end

    def do_taint_propagation(block)
      return if @visited.include?(block)
      @visited << block
      analyze_stmt(block)
      block.children.each {|child| do_taint_propagation(child) }
    end

    def is_assign?(block)
      [:LASGN].include?(block.stmts.first.type)
    end

    def analyze_stmt(block)
      if is_assign?(block)
        old_tainted_defs = @tainted_defs.dup

        operands = get_operands(block)
        if tainted_from_sources?(block, operands)
          @change = true if old_tainted_defs != @tainted_defs
        elsif tainted_from_def?(block, operands)
          @change = true if old_tainted_defs != @tainted_defs
        end
      end
    end

    def get_operands(block)
      operands = {left: [], right: []}
      ast_node = block.stmts.first
      left_var = ast_node.children[0]
      right_vars = ast_node.children[1].find_all([:VCALL, :LVAR]).map {|r| r.children[0] }
      operands[:left] << left_var
      operands[:right] += right_vars
      operands
    end

    def tainted_from_sources?(block, operands)
      status = false
      #left = Set.new(operands[:left])
      right = Set.new(operands[:right])
      sources = Set.new(@taint_sources)

      if sources.intersect?(right)
        must_taint = find_gen_of_this_var(block, operands[:left].first)
        must_taint.each do |d|
          d.mark_tainted
          @tainted_defs << d
        end
        status = true
      end
      status
    end

    def tainted_from_def?(block, operands)
      status = false
      #left = Set.new(operands[:left])
      right = Set.new(operands[:right])
      right.each do |var_right|
        defs_of_var = block.in.select {|d| d.var?(var_right) }
        defs_of_var.each do |def_in|
          if def_in.is_tainted?
            status = true
            must_taint = find_gen_of_this_var(block, operands[:left].first)
            must_taint.each do |d|
              d.mark_tainted
              d.taint_by(def_in)
              @tainted_defs << d
            end
          end
        end
      end
      status
    end

    def find_gen_of_this_var(block, var_name)
      block.gen.select {|d| d.var?(var_name) }
    end

    def var_to_def(block, var_name)
      block.in.select {|d| d.var?(var_name) }
    end

    def taint_status(block, param_node)
      vars_used = param_node.find_all([:LVAR, :VCALL]).map {|var| var.children[0]}
      vars_used.each do |var_used|
        defs_in = var_to_def(block, var_used)
        tainteds = defs_in.select {|d| d.is_tainted?}
        return {def: tainteds.first, tainted: true} if tainteds.length > 0
        return {def: nil,            tainted: true} if @taint_sources.include?(var_used)
      end
      return {def: nil, tainted:false}
    end
  end
end



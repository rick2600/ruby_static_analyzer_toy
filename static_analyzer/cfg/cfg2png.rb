require 'ruby-graphviz'

class Cfg2Png
  def initialize(cfg, source_filename)
    @cfg = cfg
    @g = GraphViz.new(:G, type: :digraph)
    @visited = {}

    @lines = nil
    if !source_filename.nil?
      @lines = File.open(source_filename).readlines
    end
  end

  def save_png(filename)
    visit(@cfg.root)
    @g.output(png: filename)
  end

  def visit(node)
    node_key = node.object_id.to_s
    return @visited[node_key] if @visited.key?(node_key)
    @visited[node_key] = create_graph_node(node)

    node.children.each do |child|
      c = visit(child)
      label = ''
      label = "OUT[B#{node.block_id}]: \n"
      node.out.each do|d|
        label << "<#{d.def_id}, #{d.var}, #{d.line}, #{d.status.to_s}>\n"
      end

      if child.cond == :true
        @g.add_edges(@visited[node_key], c, color: 'green', label: label)
      elsif child.cond == :false
        @g.add_edges(@visited[node_key], c, color: 'red', label: label)
      else
        @g.add_edges(@visited[node_key], c, color: 'black', label: label)
      end
    end
    @visited[node_key]
  end

  def create_graph_node(node)
    gid = node.object_id.to_s
    shape = 'box'
    if node.stmts.empty?
      label = '*'
    else
      ast_node =  node.stmts.first
      label = ast_node.type.to_s
      label = @lines[ast_node.first_lineno-1].strip unless @lines.nil?
      label = "B#{node.block_id}: #{label}"
      shape = 'diamond' if [:IF, :WHILE].include?(ast_node.type)
    end
    @g.add_nodes(gid, label: label, shape: shape)
  end

end

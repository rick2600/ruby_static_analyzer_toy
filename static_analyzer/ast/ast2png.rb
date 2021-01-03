require 'ruby-graphviz'

class Ast2Png
  def initialize(ast)
    @ast = ast
    @g = GraphViz.new(:G, type: :digraph)
    @stack = []
  end

  def save_png(filename)
    visit(@ast)
    @g.output(png: filename)
  end

  def enter_node(node)
    gnode = create_create_gnode(node)
    @g.add_edges(@stack.last, gnode) unless @stack.empty?
    @stack.push(gnode)
  end

  def leave_node(node)
    @stack.pop
  end


  def visit(node)
    enter_node(node)
    m = if node.class == RubyVM::AbstractSyntaxTree::Node
          "visit_NODE"
        else
          "visit_#{node.class}"
        end
    send(m, node)
    leave_node(node)
  end

  def visit_NODE(node)
    node.children.each do |child|
      visit(child)
    end
  end

  def visit_NilClass(node)
  end

  def visit_Integer(node)
  end

  def visit_Symbol(node)
  end

  def visit_String(node)
  end

  def visit_Array(node)
  end

  def create_create_gnode(node)
    node = 'nil' if node.nil?
    #basic_types = [String, NilClass, FalseClass, Fixnum, Integer, Float, TrueClass, Symbol, Array]
    basic_types = [String, NilClass, FalseClass, Integer, Float, TrueClass, Symbol, Array]
    if basic_types.include? node.class
      gid = node.to_s.object_id.to_s
      gnode = @g.add_nodes(
        gid,
        label: node.to_s,
        shape: 'box',
        style: 'filled',
        fillcolor: 'orange' # lightblue2
      )
    else
      gid = node.object_id.to_s
      if node.class == RubyVM::AbstractSyntaxTree::Node
        s = node.type.to_s
      else
        s = "TODO #{node.class}"
      end

      gnode = @g.add_nodes(gid, label: s)
    end
    gnode
  end

end

require_relative 'ast/ast'
require_relative 'cfg/cfg'
require_relative 'cfg/builder'

class Function
  attr_accessor :ast, :cfg, :path, :sources, :vulnerabilities

  def initialize(path, ast_root)
    @path = path
    @_block_id = 0
    @vulnerabilities = []
    create_ast(ast_root)
    create_cfg(ast_root)
  end

  def create_ast(root)
    @ast = AST::AST.new
    @ast.root = root
  end

  def create_cfg(root)
    cfg_builder = CFG::Builder.new(self)
    @cfg = CFG::CFG.new(self)
    @cfg.root = cfg_builder.build(root.children[1])
  end

  def name
    @ast.root.children[0]
  end

  def start_line
    @ast.root.first_lineno
  end

  def block_id
    @_block_id += 1
    return @_block_id - 1
  end


end

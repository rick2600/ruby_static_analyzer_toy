require_relative 'ast/parser'
require_relative 'function'


class Artifact
  attr_accessor :path, :ast, :functions

  def initialize(path)
    #@path = File.absolute_path(path)
    @path = path
    @functions = []
    parse
    find_functions
  end

  def parse
    parser = AST::Parser.new
    @ast = parser.parse(@path)
  end

  def find_functions
    visitor = AST::Visitor.new(callback_enter: method(:on_defn))
    visitor.visit(@ast.root)
  end

  def on_defn(node)
    if node.type == :DEFN
      function = Function.new(@path, node)
      @functions << function
    end
  end
end


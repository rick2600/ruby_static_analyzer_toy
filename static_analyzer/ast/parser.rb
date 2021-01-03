require_relative 'ast'
require_relative 'visitor'

module AST
  class Parser

    def parse(filename)
      real_ast = RubyVM::AbstractSyntaxTree.parse_file(filename)
      ast = AST.new
      ast.root = real_ast
      ast
    end
  end
end

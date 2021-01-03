require_relative 'ast2png'
require_relative 'visitor'


module AST
  class AST
    attr_accessor :root, :function

    def initialize
      @root = nil
      @function = nil
    end

    def save_png(png_file)
      Ast2Png.new(@root).save_png(png_file)
    end

    def find_all(node_types)
      @find_all_param = node_types
      @find_all_result = []

      visitor = Visitor.new(
        callback_enter: method(:do_find_all)
      )
      visitor.visit(@root)
      @find_all_result
    end

    def do_find_all(node)
      @find_all_result << node if @find_all_param.include?(node.type)
    end
  end
end



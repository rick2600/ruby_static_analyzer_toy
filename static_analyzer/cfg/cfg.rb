require_relative 'cfg2png'
require_relative 'dataflow/definition'
require_relative 'dataflow/reaching_definition_analysis'
require_relative 'dataflow/taint_analysis'

require 'set'


module CFG
  class CFG
    attr_accessor :root, :path, :function, :tainted_defs

    include DataFlow::ReachingDefinitionAnalysis
    include DataFlow::TaintAnalysis

    def initialize(function)
      @function = function
      @tainted_defs = Set.new
      @def_id = 0
    end

    def save_png(png_file)
      Cfg2Png.new(self, @function.path).save_png(png_file)
    end

    def new_def_id
      current_def_id = @def_id
      @def_id += 1
      "d#{current_def_id}".to_sym
    end

  end
end



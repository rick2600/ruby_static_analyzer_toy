require 'set'

module DataFlow
  class Definition
    attr_accessor :tainted_by, :var, :def_id, :line, :status

    def initialize(def_id, var, line)
      @def_id = def_id
      @var = var
      @line = line
      @status = :untainted
      @tainted_by = Set.new
    end

    def var?(var)
      @var == var
    end

    def mark_tainted
      @status = :tainted
    end

    def is_tainted?
      @status == :tainted
    end

    def taint_by(d)
      @tainted_by << d
    end
  end
end

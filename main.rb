require_relative 'opt_parse'
require_relative 'static_analyzer/static_analyzer'


opts = parse_opts(ARGV)
static_analyzer = StaticAnalyzer.new(opts)
static_analyzer.run
